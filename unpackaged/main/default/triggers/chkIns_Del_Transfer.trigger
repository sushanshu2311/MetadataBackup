trigger chkIns_Del_Transfer on Transfer__c (before insert, after insert,  before delete, after delete, after undelete)
{
    /*  Prev Implimentation:
        Developer               :   Amit Kumar
        Product Version         :   PE 2.0
        Date of Creation        :   03/03/2009
        Purpose of Creation     :   To prevent:
                                    1. selection of 'Company' in Limited Partner while creating Transfer of Co-investment Commitment.
                                    2. selection of same LP and Partnership while creating Transfer.
                                    3. transfer of amount greater than the present amount for Commitment.
                                    4. invalid Amount Entry.
                                    And To create a new Commitment if all the above listed criterion qualifies.  
                                    
        Updated by:
        Developer               :   Shruti Garg
        Product Version         :   PE 2.5
        Date of Creation        :   06/06/2009
        Purpose of Creation     :   To prevent creation of transfer with orphan LP in Fund Commitment
                                    To prevent creation of transfer with orphan LP in Co-investment Commitment
                                    For fund Commitment, transfer is made only in case of Limited Partner 
                                    For Co-investment Commitment,transfer is made only with Institution and Limited Partner
                                    To prevent the creation of transfer with outside record type other than PE product
    */
    
    
    if(Trigger.Size == 1 && Trigger.isInsert)       // Execute only for one record
    {
        // (PE3.5, SK, 10Aug2017)
        Transfer__c ot = new Transfer__c();
        for(Transfer__c objTransf : Trigger.new){
            ot = objTransf;
        }
        
        if(Trigger.isBefore)
        {
            //(PE3.5, SK, 10Aug2017)  Transfer__c ot = Trigger.new[0];
            
            //Added Functionality by Amit Kumar
            Account[] tempAccount = [select RecordType.name,ParentId from Account where id = :ot.Transfer_to_Limited_Partner__c];
            Partnership__c[] tempPart = [Select Fund_Investment_Category__c, Total_Commitments__c from Partnership__c where Id=:ot.Transfer_to_Partnership__c];
            
            // Retriving Commitment Information.
            Commitment__c []Com = [Select Id, Limited_Partner__c ,Partnership__c, Commitment_Amount_nearest__c, Portfolio_Company__c, AllowChange__c from Commitment__c c where Id = :ot.Commitment_Name__c];
            
            
            if(tempAccount.size()>0 && tempPart.size()>0 && tempAccount[0].RecordType.name != 'Limited Partner'&& tempPart[0].Fund_Investment_Category__c == 'Fund')// && Com[0].Portfolio_Company__c == null)
                ot.Transfer_to_Limited_Partner__c.addError('Please select a "Limited Partner".');
            else if(tempAccount.size()>0 && tempPart.size()>0 && tempAccount[0].RecordType.name == 'Limited Partner' && tempAccount[0].ParentId == null)
                ot.Transfer_to_Limited_Partner__c.addError('Please associate this "Limited Partner" with a Parent Institution or select another "Limited Partner" that has a Parent.');
            else if(tempAccount.size()>0 && tempPart.size()>0 && (tempAccount[0].RecordType.name != 'Limited Partner' && tempAccount[0].RecordType.name != 'Institution' && tempAccount[0].RecordType.name != 'Individual Investor') && tempPart[0].Fund_Investment_Category__c == 'Co-Investment' && Com[0].Portfolio_Company__c != null)
                ot.Transfer_to_Limited_Partner__c.addError('Please select either a "Limited Partner", an "Individual Investor" or an "Institution".');
            else if(Com.size() > 0)
                {
                    if(Com[0].Limited_Partner__c  == ot.Transfer_to_Limited_Partner__c && Com[0].Partnership__c == ot.Transfer_to_Partnership__c)
                    {
                        ot.addError('Please select a different Limited Partner or Partnership for making a Transfer.');
                    }
                    else if(ot.Transfer_Amount_nearest__c > Com[0].Commitment_Amount_nearest__c)
                            ot.Transfer_Amount_nearest__c.addError('Transfer Amount cannot be greater than the Commitment Amount of the Commitment from which transfer is being made.');
                    else if(ot.Transfer_Amount_nearest__c > 0)
                        {
                            Id gblCommitmentId = Com[0].Id;
                            String gblCommitmentPC = Com[0].Portfolio_Company__c;
                            String strTransferLP = ot.Transfer_to_Limited_Partner__c;
                            String strTransferPart = ot.Transfer_to_Partnership__c;
                            Double oldCommitmentAmount = (Com[0].Commitment_Amount_nearest__c==null) ? 0 :Com[0].Commitment_Amount_nearest__c;
                            Double glbTransferAmount = (ot.Transfer_Amount_nearest__c==null) ? 0 : ot.Transfer_Amount_nearest__c;
                            Double newCommitmentAmount = oldCommitmentAmount - glbTransferAmount;
                            Boolean boolCommUpdated = True; // To track weather or not Old Commitment Updated. 
                
                            // Code to Update Old Commitment for Allow Changes flag ON.
                            Commitment__c updateCmt = new Commitment__c(Id = gblCommitmentId);
                            updateCmt.AllowChange__c = true;
                            updateCmt.Has_Child__c = true;
                            updateCmt.Commitment_Amount_nearest__c = newCommitmentAmount;
                            
                            // Update Old Commitment
                            Try{
                                update updateCmt;
                            }
                            Catch (DMLException e)
                            {
                                boolCommUpdated = False;
                            }
                
                            // Code to Insert New Commitment.
                            if(boolCommUpdated == True)     // If old commitment 'AllowChange' flag is updated to true.
                            {
                                Commitment__c insertCmt = new Commitment__c();
                                insertCmt.Commitment_Amount_nearest__c = glbTransferAmount;
                                insertCmt.Limited_Partner__c = strTransferLP;
                                insertCmt.Partnership__c = strTransferPart;
                                insertCmt.Portfolio_Company__c = gblCommitmentPC;
                                insertCmt.AllowChange__c = false;
                                
                                // Insert New Commitment
                                Try{
                                    insert insertCmt;

                                    // Update new Commitment Link in Transfer.
                                    ot.New_Commitment__c = insertCmt.Id;
                                }
                                Catch (DMLException e){}
                            }
                        }
                        else
                             ot.Transfer_Amount_nearest__c.addError('Invalid Amount!');
                }
        }
    
        if(Trigger.isAfter)
        {
            //(PE3.5, SK, 10Aug2017)  Transfer__c ot = Trigger.new[0];
            
            if(ot.Transfer_Amount_nearest__c > 0)
            {
                // Code to Update Old Commitment for Allow Changes flag OFF.
                Commitment__c updateCmt = new Commitment__c(Id = ot.Commitment_Name__c);
                updateCmt.AllowChange__c = false;
                // Update Old Commitment
                Try{
                    update updateCmt;
                }
                Catch (DMLException e){}
            }
        }
    }
    
    
    
    
    
    /*  
    Prev Implimentation:
    Developer               :   Amit Kumar
    Product Version         :   PE 2.0
    Date of Creation        :   03/03/2009
    Purpose of Creation     :   1. To prevent the deletion of Transfer whose resulting commitment has been changed.
                                2. To delete a transfer and a resulting commitment if above listed criteria qualifies.
    */
    if(Trigger.Size == 1)    // Execute only for single Deletion!
    {
        if(Trigger.isDelete)
        {
            // (PE3.5, SK, 10Aug2017)
            Transfer__c objTransferOld = new Transfer__c();
            for(Transfer__c objTransfer : Trigger.old){
                objTransferOld = objTransfer;
            }
            
            
            if(Trigger.isBefore)
            {
                Transfer__c ot = objTransferOld;
                if(ot.Transfer_Amount_nearest__c > 0)
                {
                    String gblTransferId=ot.Id;
                    String strNewCommitmentId = ot.New_Commitment__c;
                    Double glbTransferAmount = (ot.Transfer_Amount_nearest__c==null) ? 0 : ot.Transfer_Amount_nearest__c;
                    String strCommitmentId = ot.Commitment_Name__c;
        
                    // It counts Transfers made from new Commitment.
                    Integer countTransfer = [Select count() From Transfer__c where Commitment_Name__c = :strNewCommitmentId];
                    if(countTransfer > 0)
                        ot.addError('You cannot delete this transfer because amount in its resulting commitment has been changed. Please check the commitment.');
                    else
                    {
                        //  Retriving Commitment Information.
                        Commitment__c Com = [Select Id, Commitment_Amount_nearest__c, AllowChange__c from Commitment__c c where Id = :ot.Commitment_Name__c];
                        Double oldCommitmentAmount = Com.Commitment_Amount_nearest__c;
                        Double newCommitmentAmount = oldCommitmentAmount + glbTransferAmount;
        
                        //    Code to Update Old Commitment for Allow Changes flag ON.
                        Commitment__c updateCmt = new Commitment__c(Id=strCommitmentId);
                        updateCmt.AllowChange__c = true;
                        updateCmt.Commitment_Amount_nearest__c = newCommitmentAmount ;
                        
                        // Update Old Commitment
                        Try{
                            update updateCmt;
                        }
                        Catch (DMLException e)
                        {
                            ot.addError('Invalid Transfer delete!');
                        }
                    }
                }
            }
            
            if(Trigger.isAfter)
            {
                Transfer__c ot = objTransferOld;
                String strNewCommitmentId = ot.New_Commitment__c;
    
                if(ot.Transfer_Amount_nearest__c > 0 && strNewCommitmentId != null)
                {
                    //  Code of Deletion of New Commitment.
                    Commitment__c deleteCom = new Commitment__c(Id = strNewCommitmentId);
                    
                    //  Delete New Commitment.
                    delete deleteCom;
                    
                    //  Code to Update Old Commitment for Allow Changes flag OFF.
                    String strCommitmentId = ot.Commitment_Name__c;
                    Transfer__c []listTransfer = [Select Id, Commitment_Name__c, New_Commitment__c From Transfer__c where Commitment_Name__c = :strCommitmentId OR New_Commitment__c = :strCommitmentId];
                    Commitment__c updateCmt = new Commitment__c(Id = ot.Commitment_Name__c, Has_Child__c = false, AllowChange__c = true);
                    
                    // If there are Transfers under old commitment.
                    if(listTransfer.size()>0)   
                    {
                        for(Transfer__c out : listTransfer)
                        {
                            if(out.Commitment_Name__c == strCommitmentId && updateCmt.Has_Child__c != true)
                                updateCmt.Has_Child__c = true;
                            if(updateCmt.AllowChange__c != false)
                                updateCmt.AllowChange__c = false;
                        }
                        
                        // Update Old Commitment
                        Try{
                            update updateCmt;
                        }
                        Catch (DMLException e){ }
                    }
                }
            }
        }
        else if(Trigger.isUndelete)
        {
            for(Transfer__c t : Trigger.new)
                t.addError('Transfer once deleted cannot be undeleted.');
        }
    }
    else if(Trigger.isUndelete)
    {
        for(Transfer__c t : Trigger.new)
            t.addError('Transfer once deleted cannot be undeleted.');
    }
    
    
}