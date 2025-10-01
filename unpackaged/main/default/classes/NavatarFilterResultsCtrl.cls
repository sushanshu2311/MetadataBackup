public  without sharing class NavatarFilterResultsCtrl{
    public string operatorOperation(string field,string field_allchar,string operator,string value, string locale_info)  // Method to create dynamic query according to field type and operator
    {
        string errormsgfrTrigger;
        string row; // FOR SQL QUERY
        
        try
        {              
            
            if(value.trim()!='' && value.length()>0)
            {
                value=String.escapeSingleQuotes(value.trim());
            }
            
            
            if((field!=null)&&(operator!=null))
            { 
                //check field data type
                if((field_allchar.contains('PERCENT')) || (field_allchar.contains('REFERENCE')) || (field_allchar.contains('CURRENCY'))||(field_allchar.contains('INTEGER') ) ||(field_allchar.contains('INT') )  || (field_allchar.contains('DATETIME'))  || (field_allchar.contains('DATE')) || (field_allchar.contains('BOOLEAN')) || (field_allchar.contains('DOUBLE')) || (field_allchar.contains('MULTIPICKLIST')) || (field_allchar.contains('PICKLIST')) || (field_allchar.contains('STRING')) || (field_allchar.contains('PHONE')) || (field_allchar.contains('EMAIL')) || (field_allchar.contains('URL')) || (field_allchar.contains('TEXTAREA')))
                {
                    
                    //check operator
                    if(((operator=='=')||(operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')||(operator=='!=')))
                    {                  
                        if(field_allchar.contains('REFERENCE')) //For REFERENCE data type 
                        {
                            //rajnish 07-june 
                            if(field.tolowercase().endsWith('id')){
                                field = field.substring(0,(field.length()-2))+'.Name';
                            }
                            else if(field.tolowercase().endsWith('__c')){
                                field = field.substring(0,(field.length()-3))+'__r.Name';
                            }
                            else    
                                field = field+'.Name';
                            // rajnish 07-june
                            integer checknull_S=0;
                            value=value.trim();
                            list<string> alpha =new list<string>(); 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            }
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }
                            
                            //Faizan putted condition for Less than and Greater than                                                                              
                            if( ((value.length()==0 ) || (alpha.size()==0) )&& ((operator=='=')||(operator=='!=')||(operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')))
                            {  
                                
                                row=field+' '+operator+' '+'\'\'';  
                                
                            } 
                            else
                            {
                                if( (alpha.size()==1))
                                {
                                    if((operator=='=')||(operator=='!=')||(operator=='!=')||(operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) 
                                    {
                                        if((operator=='!='))
                                        {  
                                            /* I have modified the If Else Condition for Bug No:: 00020591 Modified by: Ashwani Dua Dated: 26 May 2017 */
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                            }  
                                        }
                                        else
                                        {
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                                row+=' OR '+field+' '+operator+' '+'\''+'\' )';
                                                /* Change the above line Code for Bug No:: 00020212
                                                    Modified by: Ashwani Dua Dated: 25 April 2017 */
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                            }  
                                        }
                                    }
                                    
                                    
                                    
                                }
                                else if(alpha.size()>1)
                                { 
                                    alpha[0]=alpha[0].trim();                       
                                    if((operator=='=')||(operator=='!=')||(operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>='))
                                    {
                                    // Change the Filter Condition for Bug No:: 00019712 Modified by: Ashwani Dua Dated: 15 May 2017    
                                    if((operator=='!='))
                                    {
                                        if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_S!=1) 
                                                {
                                                    row+=' '+'AND '+ field+' '+operator+' '+'null';
                                                    checknull_S=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    row+=' '+'AND '+ field+' '+operator+' '+'\''+s+'\''; 
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_S!=1)
                                            {
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }                                                  
                                    }
                                    
                                    else
                                        {
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';    
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_S!=1) 
                                                {
                                                    
                                                    row+=' '+'OR '+ field+' '+operator+' '+'null';    
                                                    checknull_S=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\'';        
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_S!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                    }
                                }
                            }     
                        }              
                        if(field_allchar.contains('DATETIME')) //For DATETIME data type 
                        {
                            value=value.trim();
                            if(value.length()==0) 
                            {
                                if(((operator=='=')||(operator=='!=')))
                                {
                                    row=field+' '+operator+' null';  
                                }
                                else
                                {
                                    row='('+field+' = null OR '+field+' != null )';  
                                }                        
                            }
                            else
                            {
                                string strConvertedDate='';
                                string strConvertedDate1='';
                                string strConvertedDate_other='';
                                
                                datetime ddt1=datetime.valueof(value);
                                
                                list<string> nxtdate =new list<string>();
                                list<string> nxtdate1 =new list<string>();
                                list<string>gettimelst=value.split(' ');
                                datetime ddtnextday1;
                                if(gettimelst[1].trim()=='00:00:00')
                                {
                                    ddtnextday1=datetime.valueof(ddt1.addDays(1));
                                }
                                else
                                {
                                    if(operator=='=')
                                    {
                                        ddtnextday1=datetime.valueof(ddt1.addMinutes(1));
                                    }
                                    else
                                        ddtnextday1=datetime.valueof(ddt1.addMinutes(59)); 
                                }
                                
                                string day1_str=string.valueOfGmt(ddt1);
                                if(operator=='>' ){
                                    if(gettimelst[1].trim()=='00:00:00')
                                    {
                                        day1_str=string.valueOfGmt(ddt1.addDays(1));
                                    }
                                    else
                                        day1_str=string.valueOfGmt(ddt1.addMinutes(1));
                                }
                                
                                string nxtdaystr=string.valueOfGmt(ddtnextday1);
                                if((operator=='<')){
                                    if(gettimelst[1].trim()=='00:00:00')
                                    {
                                        nxtdaystr=string.valueOfGmt(ddt1.addDays(-1));
                                    }
                                    else
                                        nxtdaystr=string.valueOfGmt(ddt1.addMinutes(-1));
                                }
                                
                                if((operator=='!=')){
                                    if(gettimelst[1].trim()=='00:00:00')
                                    {
                                        nxtdaystr=string.valueOfGmt(ddt1.addDays(1));
                                    }
                                    else{
                                        day1_str=string.valueOfGmt(ddt1.addMinutes(1));
                                        nxtdaystr=string.valueOfGmt(ddt1.addMinutes(-1));
                                    }
                                }
                                
                                
                                nxtdate=day1_str.split(' ');
                                nxtdate1=nxtdaystr.split(' ');
                                
                                strConvertedDate=nxtdate[0]+'T'+nxtdate[1]+'Z';
                                strConvertedDate1=nxtdate1[0]+'T'+nxtdate1[1]+'Z';
                                strConvertedDate_other=nxtdate1[0]+'T'+nxtdate1[1]+'Z';
                                strConvertedDate_other=strConvertedDate;
                                
                                
                                if(operator=='=')
                                {
                                    row=field+' >= '+strConvertedDate+' and '+field+' < '+strConvertedDate1;
                                }
                                else if((operator=='<=') || (operator=='>='))
                                {
                                    row='(('+field+' > '+strConvertedDate+' and '+field+' < '+strConvertedDate1+')  OR '+field+' '+operator+' '+strConvertedDate +'  )'; 
                                }   
                                else if((operator=='!=') )  
                                {
                                    if(gettimelst[1].trim()=='00:00:00')
                                    {
                                        row='( NOT ('+field+' >= '+strConvertedDate+' and '+field+' < '+strConvertedDate1+'))';
                                    }
                                    else
                                        row='( NOT ('+field+' <= '+strConvertedDate+' and '+field+' >= '+strConvertedDate1+'))';
                                    
                                    row+=' OR ('+field+' =  null )'; 
                                }
                                else if(operator=='<')
                                {
                                    row=field+' '+operator+' '+strConvertedDate;
                                }
                                else if(operator=='>')
                                {                        
                                    row=field+' '+'>='+' '+strConvertedDate_other;                       
                                }  
                                row='('+row+')';
                                
                            }
                        }
                        else if(field_allchar.contains('DATE')) //For DATE data type 
                        {
                            
                            value=value.trim();
                            if(value.length()==0)
                            {                         
                                if(((operator=='=')||(operator=='!=')))
                                {
                                    row=field+' '+operator+' null';  
                                }
                                else
                                {
                                    row='('+field+' = null OR '+field+' != null )';  
                                }    
                            }
                            else
                            {
                                datetime dd=date.valueof(value);
                                
                                string strgmtdtetme=string.valueOfGmt(dd);
                                
                                list<string> datealpha =new list<string>();  
                                
                                if(strgmtdtetme.length()>0)
                                {
                                    datealpha=strgmtdtetme.split(' ');               
                                }                      
                                string strConvertedDate=datealpha[0];
                                datetime dd1=dd.addDays(1);
                                
                                string strgmtdtetme2=string.valueOfGmt(dd1);
                                
                                
                                list<string> datealpha2 =new list<string>();  
                                
                                if(strgmtdtetme2.length()>0)
                                {
                                    datealpha2=strgmtdtetme2.split(' ');               
                                }                      
                                string strConvertedDate_other=datealpha2[0];
                                string strConvertedDate1=datealpha2[0];
                                datetime dd2=dd.addDays(-1);
                                
                                string strgmtdtetme22=string.valueOfGmt(dd2);
                                
                                
                                list<string> datealpha22 =new list<string>();  
                                
                                if(strgmtdtetme22.length()>0)
                                {
                                    datealpha22=strgmtdtetme22.split(' ');               
                                }                      
                                string strConvertedDate_other_1=datealpha22[0];
                                
                                
                                
                                if(operator=='=')
                                {
                                    row=field+' '+'>='+' '+strConvertedDate+' and '+field+' '+'<'+' '+strConvertedDate_other;
                                }
                                else if(operator=='<=')
                                {
                                    row=field+' '+'<'+' '+strConvertedDate_other;
                                }
                                else if(operator=='>=')
                                {
                                    row=field+' '+'>='+' '+strConvertedDate;
                                }
                                else if(operator=='<')
                                {
                                    row=field+' '+'<'+' '+strConvertedDate;
                                }
                                else if(operator=='>')
                                {
                                    row=field+' '+'>='+' '+strConvertedDate_other;
                                }
                                else if((operator=='!=') )  
                                {
                                    row='(NOT('+field+' '+'>'+' '+strConvertedDate_other_1+' and '+field+' '+'<'+' '+strConvertedDate_other+')) OR ('+field+' '+'='+' '+null+')';
                                }                       
                                else 
                                {                        
                                    row=field+' '+operator+' '+strConvertedDate; 
                                } 
                                row='('+row+')';
                            }
                        }
                        else if (field_allchar.contains('CURRENCY'))  //For CURRENCY data type 
                        { 
                            value=value.trim();               
                            integer checknull=0;
                            list<string> alpha =new list<string>();                 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');
                                
                            } 
                            integer chksize=0;                            
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }
                            if(((operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) && ((value=='')||(alpha.size()==0)))
                            {
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }                                                                                              
                            else if( ((value.length()==0 ) || (alpha.size()==0) )&& ((operator=='=')||(operator=='!=')))
                            {                  
                                row=field+' '+operator+' '+'null';                
                            } 
                            else
                            {                                           
                                if( (alpha.size()==1 ))
                                {
                                    if(alpha[0]!='')
                                    {
                                        if(alpha[0].contains('.') )
                                        {
                                        }
                                        else
                                        {
                                            
                                            decimal v=decimal.valueof(alpha[0]);
                                            v=v+0.0;
                                            alpha[0]=string.valueof(v);                                         
                                        }
                                    }
                                    
                                    if(((operator=='=')||(operator=='!=')))
                                    {
                                        if((operator=='='))
                                        {                           
                                            alpha[0]=alpha[0].trim();
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+alpha[0];                        
                                            }  
                                        }
                                        else
                                        {                           
                                            alpha[0]=alpha[0].trim();
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+alpha[0];                        
                                            }  
                                        }                                               
                                    }   
                                    else
                                    {
                                        alpha[0]=alpha[0].trim();
                                        row=field+' '+operator+' '+alpha[0];        
                                    }           
                                }               
                                else if(alpha.size()>1)
                                {  
                                    if(alpha[0]!='')
                                    {
                                        
                                        if(alpha[0].contains('.') )
                                        {
                                        }
                                        else
                                        {
                                            
                                            decimal v=decimal.valueof(alpha[0]);
                                            v=v+0.0;
                                            alpha[0]=string.valueof(v);                                         
                                        }
                                    }
                                    
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(alpha[0].length()==0)
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            } 
                                            else                                
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0]; 
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;
                                                    checknull=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    if(s.contains('.'))
                                                    {
                                                    }
                                                    else
                                                    {
                                                        
                                                        decimal v=decimal.valueof(s);
                                                        v=v+0.0;
                                                        s=string.valueof(v);                                            
                                                    }
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;   
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                        else
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(alpha[0].length()==0)
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }  
                                            else                                
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0]; 
                                            }
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;
                                                    checknull=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    if(s.contains('.'))
                                                    {
                                                    }
                                                    else
                                                    {
                                                        
                                                        decimal v=decimal.valueof(s);
                                                        v=v+0.0;
                                                        s=string.valueof(v);                                            
                                                    }
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;  
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull!=1)
                                            {
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                        }                         
                                    }
                                    else
                                    {
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')
                                            {
                                                continue;       
                                            }
                                            else
                                            {
                                                s=s.trim();
                                                if(s.contains('.'))
                                                {
                                                }
                                                else
                                                {
                                                    
                                                    decimal v=decimal.valueof(s);
                                                    v=v+0.0;
                                                    s=string.valueof(v);                                            
                                                }
                                                row= '('+field+' '+operator+' '+s;
                                                break;
                                            }                              
                                        }                     
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')                       
                                                continue;
                                            if(s.contains('.'))
                                            {
                                            }
                                            else
                                            {
                                                
                                                decimal v=decimal.valueof(s);
                                                v=v+0.0;
                                                s=string.valueof(v);                                            
                                            }
                                            row+=' '+'OR '+ field+' '+operator+' '+s;
                                        }
                                        if(row==null)
                                        {
                                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                        }
                                        else
                                        {
                                            row+=')';   
                                        }
                                        
                                    }             
                                }                                  
                            }
                        }
                        else if(field_allchar.contains('BOOLEAN')) //For BOOLEAN data type 
                        {
                            value=value.trim();
                            list<string> alpha =new list<string>(); 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            }  
                            
                            // Check for operator is equals to "not equal"       
                            if(operator=='!=')
                            {                    
                                if(value=='' || alpha.size()==0)
                                {
                                    row=field+' '+operator+' false';  
                                }
                                else
                                { 
                                    if(alpha.size()==1)
                                    {
                                        if(alpha[0]=='')
                                        {
                                            row=field+' '+operator+' false';  
                                        }
                                        else
                                        {
                                            row=field+' '+operator+' '+alpha[0];  
                                        }                           
                                    }
                                    if(alpha.size()>1)
                                    { 
                                        row=field+' '+operator+' false';              
                                    }    
                                }                    
                            }                    
                            else if(operator=='=')
                            {                    
                                if(value=='' || alpha.size()==0)
                                {
                                    row=field+' '+operator+' false';
                                }
                                else
                                {                      
                                    if(alpha.size()==1)
                                    {
                                        alpha[0]=alpha[0].trim();
                                        if(alpha[0]=='')
                                        {
                                            row=field+' '+operator+' false';  
                                        }
                                        else
                                        {
                                            row=field+' '+operator+' '+alpha[0];  
                                        }     
                                    }
                                    if(alpha.size()>1)
                                    { 
                                        row=field+' '+operator+' false';                
                                    }    
                                }                                
                            }
                        }
                        else if(field_allchar.contains('DOUBLE') ) //For DOUBLE data type 
                        {
                            value=value.trim();
                            integer checknull_D=0;
                            list<string> alpha =new list<string>();                 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            } 
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }               
                            if(((operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) && ((value=='')||(alpha.size()==0)))
                            {
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }                                                                                              
                            else if( ((value.length()==0 ) || (alpha.size()==0) )&& ((operator=='=')||(operator=='!=')))
                            {                  
                                row=field+' '+operator+' '+'null';                
                            } 
                            else
                            {                                           
                                if( (alpha.size()==1))
                                {
                                    alpha[0]=alpha[0].trim();
                                    
                                    if(alpha[0]!='')
                                    {
                                        if(alpha[0].contains('.') )
                                        {
                                        }
                                        else
                                        {
                                            
                                            decimal v=decimal.valueof(alpha[0]);
                                            v=v+0.0;
                                            alpha[0]=string.valueof(v);                                         
                                        }
                                    }
                                    
                                    
                                    if(((operator=='=')||(operator=='!=')))
                                    { 
                                        if((operator=='='))
                                        {
                                            if(value.endsWith(','))
                                            {
                                                
                                                
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+alpha[0];                        
                                            }  
                                        }
                                        else
                                        {
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+alpha[0];                        
                                            }  
                                        }  
                                    }   
                                    else
                                    {                         
                                        row=field+' '+operator+' '+alpha[0];        
                                    }           
                                }               
                                else if(alpha.size()>1)
                                {   
                                    
                                    alpha[0]=alpha[0].trim();
                                    if(alpha[0]!='')
                                    {
                                        alpha[0]=alpha[0].trim();
                                        if(alpha[0].contains('.') )
                                        {
                                        }
                                        else
                                        {
                                            
                                            decimal v=decimal.valueof(alpha[0]);
                                            v=v+0.0;
                                            alpha[0]=string.valueof(v);                                         
                                        }
                                    }
                                    
                                    
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0];   
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_D!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;
                                                    checknull_D=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    if(s.contains('.'))
                                                    {
                                                    }
                                                    else
                                                    {
                                                        
                                                        decimal v=decimal.valueof(s);
                                                        v=v+0.0;
                                                        s=string.valueof(v);                                            
                                                    }
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;   
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }                               
                                            if(value.endsWith(',') && checknull_D!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                        else
                                        {  
                                            alpha[0]=alpha[0].trim();                           
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0];   
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_D!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;
                                                    checknull_D=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    if(s.contains('.'))
                                                    {
                                                    }
                                                    else
                                                    {
                                                        
                                                        decimal v=decimal.valueof(s);
                                                        v=v+0.0;
                                                        s=string.valueof(v);                                            
                                                    }
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;  
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_D!=1)
                                            {
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }                        
                                    }
                                    else
                                    {
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')
                                            {
                                                continue;       
                                            }
                                            else
                                            {
                                                s=s.trim();
                                                if(s.contains('.'))
                                                {
                                                }
                                                else
                                                {
                                                    
                                                    decimal v=decimal.valueof(s);
                                                    v=v+0.0;
                                                    s=string.valueof(v);                                            
                                                }
                                                
                                                row= '('+field+' '+operator+' '+s;
                                                break;
                                            }                              
                                        }                     
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')                       
                                                continue;
                                            if(s.contains('.'))
                                            {
                                            }
                                            else
                                            {
                                                
                                                decimal v=decimal.valueof(s);
                                                v=v+0.0;
                                                s=string.valueof(v);                                            
                                            }
                                            
                                            row+=' '+'OR '+ field+' '+operator+' '+s;
                                        }
                                        if(row==null)
                                        {
                                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                        }
                                        else
                                        {
                                            row+=')';   
                                        }
                                        
                                    }             
                                }                                  
                            }
                            
                        }                
                        else if( field_allchar.contains('INTEGER') || field_allchar.contains('INT')) //For INTEGER data type 
                        {
                            value=value.trim();
                            integer checknull_D=0;
                            list<string> alpha =new list<string>();                 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            } 
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }               
                            if(((operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) && ((value=='')||(alpha.size()==0)))
                            {
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }                                                                                              
                            else if( ((value.length()==0 ) || (alpha.size()==0) )&& ((operator=='=')||(operator=='!=')))
                            {                  
                                row=field+' '+operator+' '+'null';                
                            } 
                            else
                            {                                           
                                if( (alpha.size()==1))
                                {
                                    alpha[0]=alpha[0].trim();
                                    
                                    if(alpha[0]!='')
                                    {
                                        if(alpha[0].contains('.') )
                                        {   
                                            list<string> alpha_forinteger =new list<string>();     
                                            alpha_forinteger=alpha[0].split('\\.');      
                                            
                                            alpha[0]=alpha_forinteger[0];
                                        }  
                                        
                                    }
                                    
                                    
                                    if(((operator=='=')||(operator=='!=')))
                                    { 
                                        if((operator=='='))
                                        {
                                            if(alpha[0]=='')
                                            {
                                                row=field+' '+operator+' '+'null';   
                                            }
                                            else if(value.endsWith(','))
                                            {   
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+alpha[0];                        
                                            }  
                                        }
                                        else
                                        {
                                            if(alpha[0]=='')
                                            {
                                                row=field+' '+operator+' '+'null';   
                                            }
                                            else  if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+alpha[0];                        
                                            }  
                                        }  
                                    }   
                                    else
                                    { 
                                        if(alpha[0]=='')
                                        {
                                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                        }
                                        else
                                        {
                                            row=field+' '+operator+' '+alpha[0]; 
                                        }                           
                                    }           
                                }               
                                else if(alpha.size()>1)
                                {   
                                    alpha[0]=alpha[0].trim();
                                    if(alpha[0]!='')
                                    {
                                        alpha[0]=alpha[0].trim();
                                        if(alpha[0].contains('.') )
                                        {
                                            list<string> alpha_forinteger =new list<string>();     
                                            alpha_forinteger=alpha[0].split('\\.');      
                                            
                                            alpha[0]=alpha_forinteger[0];
                                        }
                                        
                                    }                       
                                    
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0];   
                                            }                           
                                            for(string s:alpha)
                                            {
                                                if(s.contains('.'))
                                                {
                                                    list<string> alpha_forinteger =new list<string>();     
                                                    alpha_forinteger=s.split('\\.');      
                                                    
                                                    s=alpha_forinteger[0];                                  
                                                }
                                                
                                                s=s.trim();
                                                if(s=='' && checknull_D!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;
                                                    checknull_D=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {  
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;   
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }                               
                                            if(value.endsWith(',') && checknull_D!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }  
                                        }
                                        else
                                        {  
                                            alpha[0]=alpha[0].trim();                           
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0];   
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s.contains('.'))
                                                {
                                                    list<string> alpha_forinteger =new list<string>();     
                                                    alpha_forinteger=s.split('\\.');      
                                                    
                                                    s=alpha_forinteger[0];
                                                }
                                                if(s=='' && checknull_D!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;
                                                    checknull_D=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    
                                                    
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;  
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_D!=1)
                                            {
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }     
                                        }                        
                                    }
                                    else
                                    {
                                        for(string s:alpha)
                                        {
                                            if(s.contains('.'))
                                            {
                                                list<string> alpha_forinteger =new list<string>();     
                                                alpha_forinteger=s.split('\\.');      
                                                
                                                s=alpha_forinteger[0];
                                            }
                                            s=s.trim();
                                            if(s=='')
                                            {
                                                continue;       
                                            }
                                            else
                                            {
                                                s=s.trim();
                                                
                                                
                                                
                                                row= '('+field+' '+operator+' '+s;
                                                break;
                                            }                              
                                        }                     
                                        for(string s:alpha)
                                        {
                                            if(s.contains('.'))
                                            {
                                                list<string> alpha_forinteger =new list<string>();     
                                                alpha_forinteger=s.split('\\.');      
                                                
                                                s=alpha_forinteger[0];
                                            }
                                            s=s.trim();
                                            if(s=='')                       
                                                continue;
                                            
                                            
                                            
                                            row+=' '+'OR '+ field+' '+operator+' '+s;
                                        }
                                        if(row==null)
                                        {
                                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                        }
                                        else
                                        {
                                            row+=')';   
                                        }
                                        
                                    }             
                                }                                  
                            }
                            
                        } 
                        else if (field_allchar.contains('PERCENT'))  //For PERCENT data type 
                        { 
                            integer checknull_P=0;      
                            list<string> alpha =new list<string>();                 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            } 
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }
                            
                            if(((operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) && ((value.length()==0)||(alpha.size()==0)))
                            {
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }                                                                                               
                            else if( ((value.length()==0 ) || (alpha.size()==0) ) && ((operator=='=')||(operator=='!=')))
                            {                                
                                row=field+' '+operator+' '+'null';                
                            } 
                            else
                            {                   
                                if( (alpha.size()==1))
                                { 
                                    if(alpha[0].endsWith('%'))
                                    {
                                        alpha[0] = alpha[0].replace('%','');
                                    }
                                    if(alpha[0]!='')
                                    {
                                        if(alpha[0].contains('.'))
                                        {
                                        }
                                        else
                                        {
                                            
                                            decimal v=decimal.valueof(alpha[0]);
                                            v=v+0.0;
                                            alpha[0]=string.valueof(v);                                         
                                        }
                                    }
                                    if(((operator=='=')||(operator=='!=')))
                                    {
                                        if((operator=='='))
                                        {
                                            alpha[0]=alpha[0].trim();
                                            
                                            if(value.endsWith(','))
                                            {
                                                
                                                if(alpha[0].endsWith('%'))
                                                {
                                                    alpha[0] = alpha[0].replace('%','');
                                                }
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                if(alpha[0].endsWith('%'))
                                                {
                                                    alpha[0] = alpha[0].replace('%','');
                                                }
                                                row=field+' '+operator+' '+alpha[0];    
                                            }
                                        }
                                        else
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(value.endsWith(','))
                                            {
                                                
                                                if(alpha[0].endsWith('%'))
                                                {
                                                    alpha[0] = alpha[0].replace('%','');
                                                }
                                                row='( '+field+' '+operator+' '+alpha[0];
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                if(alpha[0].endsWith('%'))
                                                {
                                                    alpha[0] = alpha[0].replace('%',' ');
                                                }
                                                row=field+' '+operator+' '+alpha[0];    
                                                
                                            }              
                                        }
                                    }                           
                                    else
                                    {
                                        alpha[0]=alpha[0].trim();
                                        if(alpha[0].endsWith('%'))
                                        {
                                            alpha[0] = alpha[0].replace('%','');
                                        }
                                        row=field+' '+operator+' '+alpha[0];        
                                    }           
                                }               
                                else if(alpha.size()>1)
                                { 
                                    
                                    if(alpha[0]!='')
                                    {
                                        if(alpha[0].endsWith('%'))
                                        {
                                            alpha[0] = alpha[0].replace('%','');
                                        } 
                                        if(alpha[0].contains('.'))
                                        {
                                        }
                                        else
                                        {
                                            
                                            decimal v=decimal.valueof(alpha[0]);
                                            v=v+0.0;
                                            alpha[0]=string.valueof(v);                                         
                                        }
                                    }                   
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(alpha[0].endsWith('%'))
                                            {
                                                alpha[0] = alpha[0].replace('%','');
                                            } 
                                            
                                            if(alpha[0].length()==0)
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else                                
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0]; 
                                            }
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s.endsWith('%'))
                                                {
                                                    s = s.replace('%','');
                                                }
                                                if(s=='' && checknull_P!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;
                                                    checknull_P=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    if(s.contains('.'))
                                                    {
                                                    }
                                                    else
                                                    {
                                                        
                                                        decimal v=decimal.valueof(s);
                                                        v=v+0.0;
                                                        s=string.valueof(v);                                            
                                                    }
                                                    
                                                    row+=' '+'OR '+ field+' '+operator+' '+s;   
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_P!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                            
                                            
                                        }
                                        else
                                        {
                                            alpha[0]=alpha[0].trim();
                                            if(alpha[0].endsWith('%'))
                                            {
                                                alpha[0] = alpha[0].replace('%','');
                                            } 
                                            if(alpha[0].length()==0)
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            } 
                                            else                                
                                            {
                                                row= '('+field+' '+operator+' '+alpha[0]; 
                                            }                               
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s.endsWith('%'))
                                                {
                                                    s = s.replace('%','');
                                                }
                                                if(s=='' && checknull_P!=1) 
                                                {
                                                    s=null  ; 
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;
                                                    checknull_P=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    if(s.contains('.'))
                                                    {
                                                    }
                                                    else
                                                    {
                                                        
                                                        decimal v=decimal.valueof(s);
                                                        v=v+0.0;
                                                        s=string.valueof(v);                                            
                                                    }
                                                    row+=' '+'AND '+ field+' '+operator+' '+s;  
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_P!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }    
                                        }                                                 
                                    }
                                    else
                                    {
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')
                                            {
                                                continue;       
                                            }
                                            else
                                            {
                                                s=s.trim();
                                                if(s.endsWith('%'))
                                                {
                                                    s = s.replace('%','');
                                                }
                                                if(s.contains('.'))
                                                {
                                                }
                                                else
                                                {
                                                    
                                                    decimal v=decimal.valueof(s);
                                                    v=v+0.0;
                                                    s=string.valueof(v);                                            
                                                }                                        
                                                row= '('+field+' '+operator+' '+s;
                                                break;
                                            }                              
                                        }                     
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s.endsWith('%'))
                                            {
                                                s = s.replace('%','');
                                            }
                                            if(s=='')                       
                                                continue;
                                            if(s.contains('.'))
                                            {
                                            }
                                            else
                                            {
                                                
                                                decimal v=decimal.valueof(s);
                                                v=v+0.0;
                                                s=string.valueof(v);                                            
                                            }
                                            row+=' '+'OR '+ field+' '+operator+' '+s;
                                        }
                                        if(row==null)
                                        {
                                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                        }
                                        else
                                        {
                                            row+=')';   
                                        }
                                        
                                        
                                    }             
                                }                                  
                            }
                            
                        }
                        else if (field_allchar.contains('STRING')  || field_allchar.contains('URL') || field_allchar.contains('EMAIL') || field_allchar.contains('PHONE')  || field_allchar.contains('TEXTAREA'))//  For STRING & URL & EMAIL & PHONE & TEXTAREA data type
                        {
                            integer checknull_S=0;
                            value=value.trim();
                            list<string> alpha =new list<string>(); 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            } 
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }
                            
                            
                            if(((operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) && ((value=='')||(alpha.size()==0)))
                            {
                                
                                row=field+' '+operator+' '+'\''+value+'\'';
                                
                            }                                                                                              
                            else if( ((value.length()==0 ) || (alpha.size()==0) )&& ((operator=='=')||(operator=='!=')))
                            {  
                                
                                row=field+' '+operator+' '+'null';  
                                
                            } 
                            else
                            {
                                if( (alpha.size()==1))
                                {
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                            } 
                                            
                                        }
                                        else
                                        {
                                            
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                            }  
                                            
                                        }
                                    }
                                    else
                                    {
                                        if(value.endsWith(','))
                                        {                                                           
                                            row='( '+field+' '+operator+' '+'\''+alpha[0].trim()+'\''; // Trim Function Added BY sameer
                                            row+=' OR '+field+' '+operator+' '+'\'\' )';
                                        }
                                        else
                                        {
                                            row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                        } 
                                        
                                    }
                                    
                                    
                                }
                                else if(alpha.size()>1)
                                { 
                                    alpha[0]=alpha[0].trim();                       
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='=')) // for equal operator
                                        {
                                            
                                            
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_S!=1) 
                                                {
                                                    row+=' '+'OR '+ field+' '+operator+' '+'null';
                                                    checknull_S=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\''; 
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_S!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null'; 
                                                row+=')';  
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                        else // for not equal operator
                                        {
                                            
                                            
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';    
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_S!=1) 
                                                {
                                                    
                                                    row+=' '+'AND '+ field+' '+operator+' '+'null';    
                                                    checknull_S=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    row+=' '+'AND '+ field+' '+operator+' '+'\''+s+'\'';        
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            
                                            if(value.endsWith(',') && checknull_S!=1)
                                            {
                                                
                                                row+=' AND '+field+' '+operator+' '+'null'; 
                                                row+=')';   
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                    }
                                    else // for others operator
                                    {
                                        
                                        integer extra=0;
                                        integer extra1=0;
                                        
                                        
                                        
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='' || value.endsWith(',') || value.startsWith(','))
                                            {
                                                if(operator=='<')
                                                {
                                                    row='(('+field+' != '+'null) AND ('; 
                                                    extra1=1;
                                                    break;
                                                }
                                                else if( operator=='>')
                                                {
                                                    row='('+field+' != '+'null'; 
                                                    break;
                                                }
                                                else if(operator=='<='  || operator=='>=')
                                                {
                                                    row='('+field+' '+operator+' '+'\'\''; 
                                                    break;
                                                }  
                                                
                                            }
                                            else
                                            {
                                                continue;
                                            }
                                            
                                            
                                        }  
                                        
                                        if(row==null)
                                        {
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='')
                                                {
                                                    continue;
                                                }
                                                else
                                                {
                                                    if(operator=='<' )
                                                    {
                                                        row='('+field+' = '+'null OR '+field+' '+operator+' '+'\''+s+'\'';  
                                                        break;
                                                    }
                                                    else if( operator=='>' ||  operator=='>=')
                                                    {
                                                        row='(('+field+' != '+'null) AND ('+field+' '+operator+' '+'\''+s+'\''; 
                                                        extra=1;
                                                        break;
                                                    }
                                                    else if(operator=='<=')
                                                    {
                                                        row='('+field+' = '+'null OR '+field+' '+operator+' '+'\''+s+'\''; 
                                                        break;
                                                    }  
                                                    
                                                }                
                                            }
                                        }    
                                        integer extra2=0;                          
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')                       
                                                continue;
                                            if( extra1==1  &&  extra2!=1)
                                            {
                                                row+=' '+ field+' '+operator+' '+'\''+s+'\'';
                                                extra2=1;
                                            }
                                            else
                                            {
                                                row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\'';
                                            }
                                        }
                                        if(row==null)
                                        {
                                            row=field+' '+operator+' '+'\'\'';
                                        }
                                        else if(extra==1 || extra1==1)
                                        {
                                            row+='))';   
                                        }
                                        else
                                        {
                                            row+=')';   
                                        }
                                        
                                    }
                                }                   
                            }                                               
                        }
                        
                        
                        else if ((field_allchar.contains('MULTIPICKLIST')) )    //For MULTIPICKLIST data type
                        {
                            integer checknull_SMP=0;
                            value=value.trim();
                            list<string> alpha =new list<string>(); 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            } 
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }
                            if(value=='')
                            {               
                                row=field+' '+operator+' '+'\''+value+'\'';                         
                            }
                            else  if( (alpha.size()==1))
                            {
                                if((operator=='=')||(operator=='!='))
                                {
                                    if((operator=='='))
                                    {
                                        if(value.endsWith(','))
                                        {                                                           
                                            row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                            row+=' OR '+field+' '+operator+' '+'null )';
                                            
                                        }
                                        else
                                        {
                                            row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                        }  
                                    }
                                    else
                                    {
                                        if(value.endsWith(','))
                                        {                                                           
                                            row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                            row+=' AND '+field+' '+operator+' '+'null )';
                                            
                                        }
                                        else
                                        {
                                            row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                        }  
                                    }
                                }
                            } else if(alpha.size()>1)
                            { 
                                alpha[0]=alpha[0].trim();                       
                                if((operator=='=')||(operator=='!='))
                                {
                                    if((operator=='='))
                                    {
                                        if(alpha[0]=='')
                                        {
                                            row= '('+field+' '+operator+' '+'\''+value+'\'';        
                                        }
                                        else
                                        {
                                            row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                        }                           
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='' && checknull_SMP!=1) 
                                            {
                                                s=null  ; 
                                                row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\'';
                                                checknull_SMP=1;
                                                continue;
                                            }
                                            if(s!='')
                                            {
                                                row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\''; 
                                            }
                                            else
                                            {
                                                continue;
                                            }                                   
                                        }
                                        if(value.endsWith(',') && checknull_SMP!=1)
                                        {
                                            row+=' OR '+field+' '+operator+' '+'null )';
                                        }
                                        else
                                        {
                                            row+=')';  
                                        }
                                        
                                    }
                                    else
                                    {
                                        if(alpha[0]=='')
                                        {
                                            row= '('+field+' '+operator+' '+'\''+value+'\'';          
                                        }
                                        else
                                        {
                                            row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';    
                                        }                           
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='' && checknull_SMP!=1) 
                                            {
                                                s=null  ; 
                                                row+=' '+'AND '+ field+' '+operator+' '+'\''+s+'\'';    
                                                checknull_SMP=1;
                                                continue;
                                            }
                                            if(s!='')
                                            {
                                                row+=' '+'AND '+ field+' '+operator+' '+'\''+s+'\'';        
                                            }
                                            else
                                            {
                                                continue;
                                            }                                   
                                        }
                                        if(value.endsWith(',') && checknull_SMP!=1)
                                        {
                                            row+=' AND '+field+' '+operator+' '+'null )';
                                        }
                                        else
                                        {
                                            row+=')';  
                                        }
                                        
                                    }
                                }
                            }
                            
                            
                            
                            
                        }               
                        else if (field_allchar.contains('PICKLIST'))    //For PICKLIST data type
                        {
                            integer checknull_S=0;
                            value=value.trim();
                            list<string> alpha =new list<string>(); 
                            if(value.length()>0)
                            {
                                alpha=value.split(',');               
                            }
                            integer chksize=0;              
                            for(string s:alpha)
                            {
                                s=s.trim();
                                if(s=='')
                                {
                                }
                                else
                                {
                                    chksize=1;
                                }
                            }
                            if(chksize==0)
                            {
                                value='';
                            }
                            
                            
                            if(((operator=='<')||(operator=='>')||(operator=='<=')||(operator=='>=')) && ((value=='')||(alpha.size()==0)))
                            {
                                
                                if(value=='')
                                {
                                    row=field+' '+operator+' '+'\''+value+'\'';
                                }
                                else
                                {
                                    row=field+' '+operator+' '+'\''+alpha[0]+'\'';
                                }                        
                                
                            }                                                                                              
                            else if( ((value.length()==0 ) || (alpha.size()==0) )&& ((operator=='=')||(operator=='!=')))
                            {  
                                
                                row=field+' '+operator+' '+'null';  
                                
                            } 
                            else
                            {
                                if( (alpha.size()==1))
                                {
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                            }  
                                        }
                                        else
                                        {
                                            if(value.endsWith(','))
                                            {                                                           
                                                row='( '+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row=field+' '+operator+' '+'\''+alpha[0]+'\'';                       
                                            }  
                                        }
                                    }
                                    else
                                    {
                                        if(value.endsWith(','))
                                        {  
                                            if(operator=='<')
                                            {
                                                row='('+field+' != '+'null  AND '; 
                                                row+=field+' '+operator+' '+'\''+alpha[0]+'\')'; 
                                            }
                                            else if( operator=='>')
                                            {
                                                row='('+field+' != '+'null OR '; 
                                                row+=field+' '+operator+' '+'\''+alpha[0]+'\')'; 
                                                
                                            }
                                            else if(operator=='<=' )
                                            {
                                                row='('+field+' = '+'null OR '; 
                                                row+=field+' '+operator+' '+'\''+alpha[0]+'\')'; 
                                                
                                            } 
                                            else if( operator=='>=')
                                            {
                                                row='('+field+' = '+'null OR '; 
                                                row+=field+' != '+'null)'; 
                                                
                                                
                                            }                                       
                                        }
                                        else
                                        {
                                            row='('+field+' '+operator+' '+'\''+alpha[0]+'\')'; 
                                        }
                                        
                                    }
                                    
                                    
                                }
                                else if(alpha.size()>1)
                                { 
                                    alpha[0]=alpha[0].trim();                       
                                    if((operator=='=')||(operator=='!='))
                                    {
                                        if((operator=='='))
                                        {
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_S!=1) 
                                                {
                                                    
                                                    row+=' '+'OR '+ field+' '+operator+' '+'null';
                                                    checknull_S=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\''; 
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_S!=1)
                                            {
                                                row+=' OR '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                        else
                                        {
                                            if(alpha[0]=='')
                                            {
                                                row= '('+field+' '+operator+' '+'null';       
                                            }
                                            else
                                            {
                                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'\'';    
                                            }                           
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='' && checknull_S!=1) 
                                                {
                                                    
                                                    row+=' '+'AND '+ field+' '+operator+' '+'null';    
                                                    checknull_S=1;
                                                    continue;
                                                }
                                                if(s!='')
                                                {
                                                    row+=' '+'AND '+ field+' '+operator+' '+'\''+s+'\'';        
                                                }
                                                else
                                                {
                                                    continue;
                                                }                                   
                                            }
                                            if(value.endsWith(',') && checknull_S!=1)
                                            {
                                                row+=' AND '+field+' '+operator+' '+'null )';
                                            }
                                            else
                                            {
                                                row+=')';  
                                            }
                                            
                                        }
                                    }
                                    else
                                    {
                                        integer extra=0;
                                        integer extra1=0;
                                        
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='' || value.endsWith(',') || value.startsWith(','))
                                            {
                                                if(operator=='<')
                                                {
                                                    row='(('+field+' != '+'null) AND ('; 
                                                    extra1=1;
                                                    break;
                                                }
                                                else if( operator=='>')
                                                {
                                                    row='('+field+' != '+'null'; 
                                                    break;
                                                }
                                                else if(operator=='<=' )
                                                {
                                                    row='('+field+' = '+'null'; 
                                                    break;
                                                }  
                                                else if( operator=='>=')
                                                {
                                                    row='(('+field+' = '+'null OR '; 
                                                    row+=field+' != '+'null)'; 
                                                    break;
                                                }  
                                                
                                            }
                                            else
                                            {
                                                continue;
                                            }
                                            
                                            
                                        }  
                                        
                                        if(row==null)
                                        {
                                            for(string s:alpha)
                                            {
                                                s=s.trim();
                                                if(s=='')
                                                {
                                                    continue;
                                                }
                                                else
                                                {
                                                    if(operator=='<' )
                                                    {
                                                        row='('+field+' = '+'null OR '+field+' '+operator+' '+'\''+s+'\'';  
                                                        break;
                                                    }
                                                    else if( operator=='>' ||  operator=='>=')
                                                    {
                                                        row='(('+field+' != '+'null) AND ('+field+' '+operator+' '+'\''+s+'\'';  
                                                        extra=1;
                                                        break;
                                                    }
                                                    else if(operator=='<=')
                                                    {
                                                        row='('+field+' = '+'null OR '+field+' '+operator+' '+'\''+s+'\''; 
                                                        break;
                                                    }  
                                                    
                                                }        
                                                
                                            }
                                            
                                        }   
                                        
                                        integer extra2=0;                          
                                        for(string s:alpha)
                                        {
                                            s=s.trim();
                                            if(s=='')                       
                                                continue;
                                            if( extra1==1  &&  extra2!=1)
                                            {
                                                row+=' '+ field+' '+operator+' '+'\''+s+'\'';
                                                extra2=1;
                                            }
                                            else
                                            {
                                                row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'\'';
                                            }
                                        }
                                        
                                        if(row==null)
                                        {
                                            row=field+' '+operator+' '+'\'\'';
                                            
                                        }
                                        else if(extra==1 || extra1==1)
                                        {
                                            row+='))';   
                                        }
                                        else
                                        {
                                            row+=')';   
                                        }
                                        
                                    }
                                }                   
                            }                 
                            
                            
                        }                
                    }
                    else if(operator=='like') //For LIKE operator
                    {
                        if(field_allchar.contains('REFERENCE')) //For REFERENCE data type 
                        {
                            //condition added by vivek 3nov
                            if(field.tolowercase().endsWith('id')){
                                field = field.substring(0,(field.length()-2))+'.Name';                   
                            }
                            else if(field.tolowercase().endsWith('__c')){
                                field = field.substring(0,(field.length()-3))+'__r.Name';
                                
                            }
                            else    
                                field = field+'.Name';
                        }
                        value=value.trim();
                        list<string> alpha =new list<string>(); 
                        if(value.length()>0)
                        {
                            alpha=value.split(',');               
                        }
                        integer chksize=0;              
                        if( (alpha.size()==1))
                        {
                            alpha[0]=alpha[0].trim();
                            
                            if(value.endsWith(','))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                
                            }
                            else
                            {
                                row=field+' '+operator+' '+'\''+alpha[0]+'%'+'\'';                     
                            }  
                        }
                        else if(alpha.size()>1)
                        { 
                            if( (value.endsWith(',')) || (value.startsWith(',')))
                            {                                  
                                
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                                
                            }
                            else
                            {
                                alpha[0]=alpha[0].trim();
                                row= '('+field+' '+operator+' '+'\''+alpha[0]+'%'+'\'';  
                                for(string s:alpha)
                                {
                                    s=s.trim();
                                    if(s=='') 
                                    {                                           
                                        row='('+field+' = '+'null OR '+field+' != '+'null' ; 
                                        break;
                                    }
                                    else
                                    {
                                        row+=' '+'OR '+ field+' '+operator+' '+'\''+s+'%'+'\'';
                                    }                                 
                                }
                                row+=')';               
                                
                            }  
                        }
                        else if( ( value=='' ) || ( alpha.size()==0 ) || (value.endsWith(',') ) || (value.startsWith(',')))
                        {
                            row='('+field+' = '+'null OR '+field+' != '+'null)' ;                        
                        }                   
                    }
                    //
                    /*else if(operator=='<') //For Less Than operator
                    {                        
                        
                        if(field_allchar.contains('REFERENCE')) //For REFERENCE data type 
                        {
                            //condition added by vivek 3nov
                            if(field.tolowercase().endsWith('id')){
                                field = field.substring(0,(field.length()-2))+'.Name';                   
                            }
                            else if(field.tolowercase().endsWith('__c')){
                                field = field.substring(0,(field.length()-3))+'__r.Name';
                                
                            }
                            else    
                                field = field+'.Name';
                        }
                        value=value.trim();               
                        list<string> alpha =new list<string>(); 
                        if(value.length()>0)
                        {
                            alpha=value.split(',');               
                        } 
                        integer chksize=0;              
                        for(string s:alpha)
                        {
                            s=s.trim();
                            if(s=='')
                            {
                            }
                            else
                            {
                                chksize=1;
                            }
                        }
                        if(chksize==0)
                        {
                            value='';
                        }
                        
                        
                        if( ( value=='' ) || ( alpha.size()==0 ) || (value.endsWith(',') ) || (value.startsWith(',')))
                        {
                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            
                        }                                                                                              
                        else if( (alpha.size()==1))
                        {
                            alpha[0]=alpha[0].trim();
                            
                            
                            if(value.endsWith(','))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }
                            else
                            {
                                row=field+' '+'like \'%'+alpha[0]+'%\'';                    
                            }  
                            
                            
                        }
                        else if(alpha.size()>1)
                        { 
                            if( (value.endsWith(',')) || (value.startsWith(',')))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }
                            else
                            {
                                alpha[0]=alpha[0].trim();
                                row= '('+field+' '+'like \'%'+alpha[0]+'%\'';
                                for(string s:alpha)
                                {
                                    s=s.trim();
                                    if(s=='') 
                                    {                                           
                                        row='('+field+' = '+'null OR '+field+' != '+'null' ; 
                                        break;
                                    }
                                    else
                                    {
                                        row+=' '+'OR '+ field+' '+'like \'%'+s+'%\'';
                                    }                                  
                                }
                                row+=')';               
                                
                            }  
                        }                          
                    }
                    
                    else if(operator=='>') //For Greater Than operator
                    {
                        
                        
                        
                        if(field_allchar.contains('REFERENCE')) //For REFERENCE data type 
                        {
                            //condition added by vivek 3nov
                            if(field.tolowercase().endsWith('id')){
                                field = field.substring(0,(field.length()-2))+'.Name';                   
                            }
                            else if(field.tolowercase().endsWith('__c')){
                                field = field.substring(0,(field.length()-3))+'__r.Name';
                                
                            }
                            else    
                                field = field+'.Name';
                        }
                        value=value.trim();               
                        list<string> alpha =new list<string>(); 
                        if(value.length()>0)
                        {
                            alpha=value.split(',');               
                        } 
                        integer chksize=0;              
                        for(string s:alpha)
                        {
                            s=s.trim();
                            if(s=='')
                            {
                            }
                            else
                            {
                                chksize=1;
                            }
                        }
                        if(chksize==0)
                        {
                            value='';
                        }
                        
                        
                        if( ( value=='' ) || ( alpha.size()==0 ) || (value.endsWith(',') ) || (value.startsWith(',')))
                        {
                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            
                        }                                                                                              
                        else if( (alpha.size()==1))
                        {
                            alpha[0]=alpha[0].trim();
                            
                            
                            if(value.endsWith(','))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }
                            else
                            {
                                row=field+' '+'like \'%'+alpha[0]+'%\'';                    
                            }  
                            
                            
                        }
                        else if(alpha.size()>1)
                        { 
                            if( (value.endsWith(',')) || (value.startsWith(',')))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }
                            else
                            {
                                alpha[0]=alpha[0].trim();
                                row= '('+field+' '+'like \'%'+alpha[0]+'%\'';
                                for(string s:alpha)
                                {
                                    s=s.trim();
                                    if(s=='') 
                                    {                                           
                                        row='('+field+' = '+'null OR '+field+' != '+'null' ; 
                                        break;
                                    }
                                    else
                                    {
                                        row+=' '+'OR '+ field+' '+'like \'%'+s+'%\'';
                                    }                                  
                                }
                                row+=')';               
                                
                            }  
                        }                          
                    }*/
                    //
                    
                    else if(operator=='contains') //For CONTAINS operator
                    {                 
                        
                        if(field_allchar.contains('REFERENCE')) //For REFERENCE data type 
                        {
                            //condition added by vivek 3nov
                            if(field.tolowercase().endsWith('id')){
                                field = field.substring(0,(field.length()-2))+'.Name';                   
                            }
                            else if(field.tolowercase().endsWith('__c')){
                                field = field.substring(0,(field.length()-3))+'__r.Name';
                                
                            }
                            else    
                                field = field+'.Name';
                        }
                        value=value.trim();               
                        list<string> alpha =new list<string>(); 
                        if(value.length()>0)
                        {
                            alpha=value.split(',');               
                        } 
                        integer chksize=0;              
                        for(string s:alpha)
                        {
                            s=s.trim();
                            if(s=='')
                            {
                            }
                            else
                            {
                                chksize=1;
                            }
                        }
                        if(chksize==0)
                        {
                            value='';
                        }
                        
                        
                        if( ( value=='' ) || ( alpha.size()==0 ) || (value.endsWith(',') ) || (value.startsWith(',')))
                        {
                            row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            
                        }                                                                                              
                        else if( (alpha.size()==1))
                        {
                            alpha[0]=alpha[0].trim();
                            
                            
                            if(value.endsWith(','))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }
                            else
                            {
                                row=field+' '+'like \'%'+alpha[0]+'%\'';                    
                            }  
                            
                            
                        }
                        else if(alpha.size()>1)
                        { 
                            if( (value.endsWith(',')) || (value.startsWith(',')))
                            {                                                           
                                row='('+field+' = '+'null OR '+field+' != '+'null)' ; 
                            }
                            else
                            {
                                alpha[0]=alpha[0].trim();
                                row= '('+field+' '+'like \'%'+alpha[0]+'%\'';
                                for(string s:alpha)
                                {
                                    s=s.trim();
                                    if(s=='') 
                                    {                                           
                                        row='('+field+' = '+'null OR '+field+' != '+'null' ; 
                                        break;
                                    }
                                    else
                                    {
                                        row+=' '+'OR '+ field+' '+'like \'%'+s+'%\'';
                                    }                                  
                                }
                                row+=')';               
                                
                            }  
                        }                          
                    }
                    else if(operator=='doesnotcontain')  //For DOESNOTCONTAIN operator
                    {
                        if(field_allchar.contains('REFERENCE')) //For REFERENCE data type 
                        {
                            //condition added by vivek
                            if(field.tolowercase().endsWith('id')){
                                field = field.substring(0,(field.length()-2))+'.Name';                
                            }
                            else if(field.tolowercase().endsWith('__c')){
                                field = field.substring(0,(field.length()-3))+'__r.Name';
                                
                            }
                            else    
                                field = field+'.Name';
                            
                        }
                        integer checknull_dnc=0;
                        value=value.trim();
                        list<string> alpha =new list<string>(); 
                        if(value.length()>0)
                        {
                            alpha=value.split(',');               
                        } 
                        integer chksize=0;              
                        for(string s:alpha)
                        {
                            s=s.trim();
                            if(s=='')
                            {
                            }
                            else
                            {
                                chksize=1;
                            }
                        }
                        if(chksize==0)
                        {
                            value='';
                        }
                        
                        if( ( value=='' ) || ( alpha.size()==0 ) )
                        {
                            row='('+field+' = '+'null AND '+field+' != '+'null)' ;                   
                        }                                                                                              
                        else if( (alpha.size()==1))
                        {
                            alpha[0]=alpha[0].trim();
                            if(field_allchar.contains('STRING') || field_allchar.contains('URL') || field_allchar.contains('EMAIL') || field_allchar.contains('PHONE')  || field_allchar.contains('TEXTAREA') )
                            {
                                if((value.endsWith(',')) || (value.startsWith(',')))
                                {  
                                    row= '( (NOT ' + field+' '+ 'like \'%'+alpha[0]+'%\')';                                                                     
                                    row+=' OR ('+field+' = '+'null ))' ; 
                                }
                                else
                                {
                                    row= ' (NOT ' + field+' '+ 'like \'%'+alpha[0]+'%\')';              
                                }  
                                
                            }
                            else
                            {
                                if((value.endsWith(',')) || (value.startsWith(',')))
                                {  
                                    row= '( (NOT ' + field+' '+ 'like \'%'+alpha[0]+'%\')';                                                                     
                                    row+=' AND ('+field+' != '+'null ))' ; 
                                }
                                else
                                {
                                    row= ' (NOT ' + field+' '+ 'like \'%'+alpha[0]+'%\')';              
                                }  
                                
                            }             
                        }
                        else if(alpha.size()>1)
                        { 
                            alpha[0]=alpha[0].trim(); 
                            if(field_allchar.contains('STRING') || field_allchar.contains('URL') || field_allchar.contains('EMAIL') || field_allchar.contains('PHONE')  || field_allchar.contains('TEXTAREA') )
                            {
                                if(alpha[0]=='' || value.startsWith(','))
                                {
                                    
                                }
                                else
                                {                                                                                      
                                    row= '( (NOT ' + field+' '+ 'like \'%'+alpha[0]+'%\')';  
                                }    
                                
                                for(string s:alpha)
                                {
                                    s=s.trim();
                                    if((s=='') && (checknull_dnc!=1)) 
                                    {                                        
                                        
                                        checknull_dnc=1;
                                        continue;
                                    }
                                    if(s!='')
                                    {
                                        row+='AND (NOT ' + field+' '+ 'like \'%'+s+'%\')';  
                                    }
                                    
                                }
                                if((value.endsWith(',')) && (checknull_dnc!=1) )
                                {
                                    
                                }
                                row+=')';  
                            }
                            else
                            {
                                if(alpha[0]=='' || value.startsWith(','))
                                {
                                    row='(('+field+' != '+'null)' ;  
                                }
                                else
                                {                                                                                      
                                    row= '( (NOT ' + field+' '+ 'like \'%'+alpha[0]+'%\')';  
                                }    
                                
                                for(string s:alpha)
                                {
                                    s=s.trim();
                                    if((s=='') && (checknull_dnc!=1)) 
                                    {                                        
                                        row+=' AND ('+field+' != '+'null )' ; 
                                        checknull_dnc=1;
                                        continue;
                                    }
                                    if(s!='')
                                    {
                                        row+='AND (NOT ' + field+' '+ 'like \'%'+s+'%\')';  
                                    }
                                    
                                }
                                if((value.endsWith(',')) && (checknull_dnc!=1) )
                                {
                                    row+=' AND ('+field+' != '+'null )' ; 
                                }
                                row+=')';  
                            }
                            
                            
                            
                            
                        }                                         
                    }
                    else if(((operator=='includes')||(operator=='excludes')))     //For INCLUDE & EXCLUDE operator
                    {                           
                        value=value.trim();
                        list<string> alpha =new list<string>(); 
                        if(value.length()>0)
                        {
                            alpha=value.split(',');               
                        } 
                        
                        if((operator=='includes') )
                        {
                            integer checknull_In=0;
                            if(((value=='')||(alpha.size()==0)))
                            {
                                row=field+' '+operator+' '+'(\'\')';   
                            }                                                                                                                    
                            else
                            {
                                if( (alpha.size()==1))
                                {                           
                                    if(value.endsWith(','))
                                    {                                                           
                                        row= '('+field+' '+operator+' '+'(\''+alpha[0]+'\')'; 
                                        
                                        row+=' OR '+field+' '+operator+' '+'(\'\'))';
                                    }
                                    else
                                    {
                                        row=field+' '+operator+' '+'(\''+alpha[0]+'\')';                  
                                    }                                                 
                                }
                                else if(alpha.size()>1)
                                { 
                                    alpha[0]=alpha[0].trim();                       
                                    if(alpha[0]=='' || value.startsWith(','))
                                    {
                                        row='('+field+' '+operator+' '+'(\'\')';         
                                    }
                                    else
                                    {
                                        row='('+field+' '+operator+' '+'(\''+alpha[0]+'\')';    
                                    }                           
                                    for(string s:alpha)
                                    {
                                        s=s.trim();
                                        
                                        if((s=='') && (checknull_In!=1)) 
                                        {                                        
                                            row+=' '+'OR '+ field+' '+operator+' '+'(\'\')';  
                                            checknull_In=1;
                                            continue;
                                        }
                                        if(s!='')
                                        {
                                            row+=' '+'OR '+ field+' '+operator+' '+'(\''+s+'\')'; 
                                        }
                                        
                                    }
                                    if((value.endsWith(',')) && (checknull_In!=1) )
                                    {
                                        row+=' '+'OR '+ field+' '+operator+' '+'(\'\')'; 
                                    }
                                    row+=')';  
                                    
                                }                   
                            }                     
                        }
                        else
                        {
                            
                            integer checknull_In=0;
                            if(((value=='')||(alpha.size()==0)))
                            {
                                row=field+' '+operator+' '+'(\'\')';   
                                
                            }                                                                                                                    
                            else
                            {
                                if( (alpha.size()==1))
                                {                           
                                    if(value.endsWith(','))
                                    {                                                           
                                        row=field+' '+operator+' '+'(\'\')';                                   
                                    }
                                    else
                                    {
                                        row='('+field+' '+operator+' '+'(\''+alpha[0]+'\')';  
                                        row+=' OR '+field+' includes '+'(\'\')'+' )';   
                                        
                                    }                                                 
                                }
                                else if(alpha.size()>1)
                                { 
                                    alpha[0]=alpha[0].trim();                       
                                    if(alpha[0]=='' || value.startsWith(','))
                                    {
                                        row='('+field+' '+operator+' '+'(\'\')';         
                                    }
                                    else
                                    {
                                        row='('+field+' '+operator+' '+'(\''+alpha[0]+'\')';    
                                    }                           
                                    for(string s:alpha)
                                    {
                                        s=s.trim();
                                        
                                        if((s=='') && (checknull_In!=1)) 
                                        {                                        
                                            row+=' '+'AND '+ field+' '+operator+' '+'(\'\')';  
                                            checknull_In=1;
                                            continue;
                                        }
                                        if(s!='')
                                        {
                                            row+=' '+'AND '+ field+' '+operator+' '+'(\''+s+'\')'; 
                                        }
                                        
                                    }
                                    if((value.endsWith(',')) && (checknull_In!=1) )
                                    {
                                        row+=' '+'AND '+ field+' '+operator+' '+'(\'\')'; 
                                    }
                                    row+=')';  
                                    
                                }                   
                            }                                                              
                        }
                    }                                                         
                    else 
                    {
                        row=field+' '+operator+' '+value;
                    }
                }
                else
                {
                    row=null;
                }                
            }                
        }
        catch(Exception e)
        {
            
            errormsgfrTrigger='<div class="error" id="error" style="margin-top:10px;margin-left:10px;width:98.7%"><p><span><strong>Error</strong><br/>Invalid Operator Or invalid Data.</span></p></div>';
        }
        
        return row; 
        
    }
}