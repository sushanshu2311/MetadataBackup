trigger chkIns_Upd_Del_Commitment on Commitment__c(after insert,after update ,after delete,before insert,before update,before delete,after undelete){   
    /*  Prev. Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Updation        :   26/03/2009
        Purpose of Updation     :   1.  To prevent selecting 'Institution' or 'Limited Partner' in Portfolio Company while creating Commitment for Co-investment Fund.
                                    2.  To prevent selecting 'Company' in Limited Partner while creating Commitment for Co-investment Fund.

        Date of Updation        :   14/07/2009
        Developer               :   Amit Kumar
        Product Version         :   PE 2.2
        Purpose of Updation     :   1) Dynamic Error Meassages for Portfolio Company. eg. "Please select an Institution instead of x."
                                    2) Fund Rollup Code in After Deletion.

        Date of Updation        :   08/07/2009
        Developer               :   Amit Kumar
        Product Version         :   PE 2.2
        Purpose of Updation     :   1) Validation on undelete Operation.
        
        Date of Updation        :   05/06/2012
        Developer               :   Shruti Garg
        Product Version         :   PE 2.5
        Purpose of Updation     :   1) Restrict the Creation of Fund Commitment with Orphan LP
                                    2) Restrict the Creation of Co-investment Commitment with Orphan LP
                                    3) Commitment Amount reflect to Parent Institution only in case of LP in Fund Commitment
                                    4) Commitment Amount reflect to Parent Institution only in case of LP in Co-investment Commitment
                                    5) Prevent the Outside Record type linking to Portfolio Company
                                    6) Prevent the Outside Record type linking to Limited Partner in Fund and Co-investment Commitment.
                                    7) Prevent the Outside Record type linking to Partnership in Fund and Co-investment Commitment.                         
                                    
        Date of Updation        :   05/06/2016
        Developer               :   Brahmaditya Bhaskar
        Product Version         :   PE 3.5
        Purpose of Updation     :   1) Open the restriction like if fund investment category is co- inv we can save the record without adding portfolio.
                                    2) bulkified the Trigger.
                                    3) in LP field we can add Individual investor with co-inv fund.
                                    4) In Portfolio company Field we can add property recordtype.
                                    5) We are calculating all calculation by flow.                                              
                                    
    */  
    /* 
        Developer               :  Hemendra Singh Rajawat
        Product Version         :  PE 4.5
		Date of Creation        :  30/07/2020
        Purpose of Creation     :  One More Condition added for Portfolio_Company record type with Company record type
    */
    Set<ID> PartnershipIds = new Set<ID>(); //*---This variable hold the partnership id ----*
    Set<ID> LpIDs= new Set<ID>();           //*---This variable hold the LP id ----*
    Set<ID> cmtIds= new Set<ID>();          //*---This variable hold the cmt id ----*
    
    List<Commitment__c> CmtList= new List<Commitment__c>(); //*---This variable hold the Cmt List ----*
    if(Trigger.isupdate || Trigger.isinsert){
       CmtList=Trigger.new;
    }
    if(Trigger.isdelete){
        CmtList=Trigger.old;
    }
   
    for(Commitment__c cmtobj :CmtList){
        PartnershipIds.add(cmtobj.Partnership__c);
        LpIDs.add(cmtobj.Limited_Partner__c);
        LpIDs.add(cmtobj.Portfolio_Company__c);
        if(cmtobj.id != null)
            cmtIds.add(cmtobj.id);
    }
    
    if(Trigger.isBefore){
        if(Trigger.isupdate || Trigger.isinsert){
            for(Commitment__c cmtobj:Trigger.new){
                if(cmtobj.Commitment_Amount_nearest__c ==null)
                    cmtobj.Commitment_Amount_nearest__c =0.0;
            }
        } 
        if(Trigger.isDelete)
        {   
            List<Transfer__c> OT = [Select Id,Commitment_Name__c , New_Commitment__c From Transfer__c where (Commitment_Name__c IN:CmtIds OR New_Commitment__c IN:CmtIds ) ];
            map<id,id> mapofTransferobj = new MAp<id,id>();
            map<id,id> mapofTransferobj1 = new MAp<id,id>();

            for(Transfer__c TrnsfObj:OT){   
             if(TrnsfObj.New_Commitment__c != null){
                mapofTransferobj.put(TrnsfObj.New_Commitment__c,TrnsfObj.id);
             }
             if(TrnsfObj.Commitment_Name__c != null){
                mapofTransferobj1.put(TrnsfObj.Commitment_Name__c,TrnsfObj.id);
             }
            }
            if(OT.size()>0){
                for(Commitment__c cmtobjfor:Trigger.old){
                    if(mapofTransferobj.get(cmtobjfor.Id)!=null){
                        cmtobjfor.addError('This commitment cannot be deleted because it was created as a result of a transfer from another commitment.In order to delete this commitment, please delete the transfer.');
                    }
                    else if(mapofTransferobj1.get(cmtobjfor.Id)!=null){
                             cmtobjfor.addError('This commitment cannot be deleted because a transfer has been made from this commitment.\n Please first delete the transfer made from this commitment and then delete the commitment.');
                    }
                }   
            }
        }
    }
    else if(Trigger.isUndelete){
        for(Commitment__c c : Trigger.new)
            c.addError('Commitment once deleted cannot be undeleted.');
    }    
    else{     
        Map<ID,Account> mapIdToAcc = new Map<ID, Account>([select id, RecordType.name,parentid,parent.RecordType.name From Account Where ID IN:LpIDs]);
        Map<ID,Partnership__c> mapIdToPartnership=new Map<ID, Partnership__c>([Select Fund_Investment_Category__c, Total_Commitments__c from Partnership__c where Id IN :PartnershipIds]);
        for(Commitment__c cmtobj:CmtList){
            if(!Trigger.isUndelete){
                if(Trigger.isinsert && mapIdToAcc.get(cmtobj.Limited_Partner__c).RecordType.name =='Limited Partner'&& !string.isBlank(cmtobj.Limited_Partner__c) && mapIdToAcc.get(cmtobj.Limited_Partner__c).parentid==null){
                    cmtobj.Limited_Partner__c.addError('Please associate this "Limited Partner" with a Parent Institution or select another "Limited Partner" that has a Parent.');
                }
                    
                else if(Trigger.isinsert && mapIdToPartnership.get(cmtobj.Partnership__c).Fund_Investment_Category__c== 'Fund' && mapIdToAcc.get(cmtobj.Limited_Partner__c).RecordType.name != 'Limited Partner' && !string.isBlank(cmtobj.Limited_Partner__c)){
                    cmtobj.Limited_Partner__c.addError('Please select a "Limited Partner".');            
                }
                else if((Trigger.isinsert || Trigger.isUpdate) && (mapIdToPartnership.get(cmtobj.Partnership__c).Fund_Investment_Category__c== 'Fund'||mapIdToPartnership.get(cmtobj.Partnership__c).Fund_Investment_Category__c== 'Co-Investment') && !string.isBlank(cmtobj.Portfolio_Company__c) && mapIdToAcc.get(cmtobj.Portfolio_Company__c) != null && mapIdToAcc.get(cmtobj.Portfolio_Company__c).RecordType.name != 'Company' && mapIdToAcc.get(cmtobj.Portfolio_Company__c).RecordType.name != 'Portfolio Company' && mapIdToAcc.get(cmtobj.Portfolio_Company__c).RecordType.name != 'Property'){
                    cmtobj.Portfolio_Company__c.addError('Please select the correct record type.');    
                }
                
                else if(Trigger.isinsert && mapIdToPartnership.get(cmtobj.Partnership__c).Fund_Investment_Category__c== 'Co-Investment' && (mapIdToAcc.get(cmtobj.Limited_Partner__c).RecordType.name != 'Limited Partner'&& mapIdToAcc.get(cmtobj.Limited_Partner__c).RecordType.name != 'Institution'&&mapIdToAcc.get(cmtobj.Limited_Partner__c).RecordType.name != 'Individual investor')&& !string.isBlank(cmtobj.Limited_Partner__c)){
                    cmtobj.Limited_Partner__c.addError('Please select either a "Limited Partner" or an "Institution" or an "Individual investor." ');           
                }
                else{  
                    Map<String, Object> params_cmtlst = new Map<String, Object>();
                    boolean isFlowrun = false;
                    params_cmtlst.put('cmtobj',cmtobj); 
                    Commitment__c cmtOldobj = new Commitment__c(Commitment_Amount_nearest__c =0.0);
                    if(Trigger.old!=null && !Trigger.isdelete){
                        cmtOldobj = trigger.oldmap.get(cmtobj.id);
                        if(cmtOldobj.Commitment_Amount_nearest__c ==null)
                            cmtOldobj.Commitment_Amount_nearest__c =0.0;                
                    }
                    params_cmtlst.put('cmtobj_old',cmtOldobj);
                   
                    if(Trigger.isdelete){
                        params_cmtlst.put('checkdelete',true);
                    }
                    else{
                         params_cmtlst.put('checkdelete',false);
                    }
                    
                    if(cmtobj.Portfolio_Company__c != null && ((Trigger.old != null && trigger.oldmap.get(cmtobj.id).Portfolio_Company__c != null && cmtobj.Portfolio_Company__c == trigger.oldmap.get(cmtobj.id).Portfolio_Company__c) || Trigger.old == null || (Trigger.old != null && trigger.oldmap.get(cmtobj.id).Portfolio_Company__c == null) )){
                        if(Trigger.old != null && trigger.oldmap.get(cmtobj.id).Portfolio_Company__c == null){
                             params_cmtlst.put('checkOldNull',true);
                        }
                        params_cmtlst.put('checkNewPortfolio',true);
                    }
                    
                    if(mapIdToPartnership.get(cmtobj.Partnership__c) != null && mapIdToPartnership.get(cmtobj.Partnership__c).Fund_Investment_Category__c!=null && mapIdToPartnership.get(cmtobj.Partnership__c).Fund_Investment_Category__c== 'Co-Investment'){
                        If(Trigger.isinsert ||Trigger.isdelete ||(Trigger.isupdate && ((trigger.oldmap.get(cmtobj.id).Portfolio_Company__c != null && cmtobj.Portfolio_Company__c!=null && ((cmtobj.Portfolio_Company__c == trigger.oldmap.get(cmtobj.id).Portfolio_Company__c && Trigger.oldmap.get(cmtobj.id).Commitment_Amount_nearest__c !=cmtobj.Commitment_Amount_nearest__c) || (cmtobj.Portfolio_Company__c != trigger.oldmap.get(cmtobj.id).Portfolio_Company__c) )) || (trigger.oldmap.get(cmtobj.id).Portfolio_Company__c != null && cmtobj.Portfolio_Company__c==null) || (trigger.oldmap.get(cmtobj.id).Portfolio_Company__c == null && cmtobj.Portfolio_Company__c!=null)))){ 
                            //this flow will calculate portfolio company rollup 
                            Flow.Interview.portfolio_version  helloWorldFlow = new Flow.Interview.portfolio_version(params_cmtlst);
                            helloWorldFlow.start();                         
                        }
                    }
                    
                    if(cmtobj.Limited_Partner__c != null && cmtobj.Partnership__c != null){
                        String strFundId;
                        if(Trigger.isinsert|| Trigger.isdelete||(Trigger.isupdate && Trigger.oldmap.get(cmtobj.id).Commitment_Amount_nearest__c !=cmtobj.Commitment_Amount_nearest__c)){
                            
                            //calling flow this will calculate rollup amount of Partnership 
                            Flow.Interview.Rollupflowofpartnership  helloWorldFlow_part = new Flow.Interview.Rollupflowofpartnership(params_cmtlst);
                            helloWorldFlow_part.start(); 
                            
                            String investmentcategory_fun = (String) helloWorldFlow_part.getVariableValue('investmentcategory_fun');
                            strFundId = (String) helloWorldFlow_part.getVariableValue('FundId'); 
                            //calling flow this flow will calculate the Lp rollup
                            params_cmtlst.put('Investmentcategory',investmentcategory_fun);  
                            Flow.Interview.PartnershipsumRollup  helloWorldFlow_partnership = new Flow.Interview.PartnershipsumRollup(params_cmtlst);
                            helloWorldFlow_partnership.start();                         
                        }
                        if(Trigger.isdelete){
                            //this flow will subtract the amount of fund 
                            params_cmtlst.put('FundId',strFundId);
                            Flow.Interview.Fund_Rollup  fundRollup = new Flow.Interview.Fund_Rollup(params_cmtlst);
                            fundRollup.start();
                        }   
                    }    
                }
            }
            else{
                cmtobj.addError('Commitment once deleted cannot be undeleted.');
            }
        }   
            
    }
    
}