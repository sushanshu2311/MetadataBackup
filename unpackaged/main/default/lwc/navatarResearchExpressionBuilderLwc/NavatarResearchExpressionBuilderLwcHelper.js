export default function setFilter({ curData }) {
    /*
       this filter will set the values of allowd filters as per the selected field from the FIELD picklist.
       */
    var fieldType = curData.fDataType.toUpperCase();
    var checkRecordType;
    if(curData.childRelationShipName != '' && curData.childRelationShipName != undefined){
        checkRecordType = curData.childRelationShipName.toUpperCase();
    }else{
        checkRecordType = '';
    }
    
   //alert('Field Type-->'+fieldType);
    var options = [];
    if (fieldType != '') {
        switch (fieldType) {
            case "MULTIPICKLIST":
                options = [
                    { label: "equals", value: "IN:" },
                    { label: "not equal to", value: "NOT IN:" },
                    { label: "includes", value: "includes" },
                    { label: "excludes", value: "excludes" },
                    
                ];
                break;
            case "EMAIL":
                    options = [
                        { label: "equals", value: "=" },
                        { label: "not equal to", value: "!=" },
                        { label: "less than", value: "<" },
                        { label: "greater than", value: ">" },
                        { label: "less or equal", value: "<=" },
                        { label: "greater or equal", value: ">=" },
                        { label: "contain", value: "like contain" },
                        { label: "does not contain", value: "not like" },
                        { label: "starts with", value: "like start" }
                        
                    ];
                    break;
            case "URL":
                    options = [
                            { label: "equals", value: "=" },
                            { label: "not equal to", value: "!=" },
                            { label: "less than", value: "<" },
                            { label: "greater than", value: ">" },
                            { label: "less or equal", value: "<=" },
                            { label: "greater or equal", value: ">=" },
                            { label: "contains", value: "like contain" },
                            { label: "does not contain", value: "not like" },
                            { label: "starts with", value: "like start" }
                            
                    ];
            break;
            case "PHONE":
                    options = [
                         { label: "equals", value: "=" },
                         { label: "not equal to", value: "!=" },
                         { label: "less than", value: "<" },
                        { label: "greater than", value: ">" },
                        { label: "less or equal", value: "<=" },
                        { label: "greater or equal", value: ">=" },
                        { label: "contains", value: "like contain" },
                        { label: "does not contain", value: "not like" },
                        { label: "starts with", value: "like start" }
                        ];
                    break;
            case "BOOLEAN":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" }
                ];
                break;
            case "DATE":
                
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" }
                ];
                break;
            case "DATETIME":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" }
                ];
                break;
            case "TIME":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" }
                ];
                break;
            case "DOUBLE":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" }
                ];
                break;
            case "PERCENT":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" }
                ];
                break;
            case "CURRENCY":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" }
                ];
                break;
            case "REFERENCE":
                if(checkRecordType == 'RECORDTYPE'){
                    options = [{ label: "equals", value: "IN: " },
                    { label: "not equal to", value: "NOT IN: " },
                ];
                }else{
                options = [{ label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" },
                    { label: "contains", value: "like==" },
                    { label: "does not contain", value: "not like!==" },
                    { label: "starts with", value: "like start" },
                   
                
                ];
            }
                break;
            case "PICKLIST":
                    
                    options = [{ label: "equals", value: "IN:" },
                    { label: "not equal to", value: "NOT IN:" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" },
                    { label: "contains", value: "like contain" },
                    { label: "does not contain", value: "not like" },
                    { label: "starts with", value: "like start" },
                        
                        
                    ];
                break;
                //{ label: "end with", value: "like end" },
            case "STRING":
                    
                    options = [
                        
                        { label: "equals", value: "=" },
                        { label: "not equal to", value: "!=" },
                        { label: "less than", value: "<" },
                        { label: "greater than", value: ">" },
                        { label: "less or equal", value: "<=" },
                        { label: "greater or equal", value: ">=" },
                        { label: "contains", value: "like contain" },
                        { label: "does not contain", value: "not like" },
                        { label: "starts with", value: "like start" },
                        

                    ];
                break;
            case "TEXTAREA":
                    
                options = [
                    
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" },
                    { label: "contains", value: "like contain" },
                    { label: "does not contain", value: "not like" },
                    { label: "starts with", value: "like start" },
                    

                ];
            break;
                case "NUMBER":
                    
                    options = [
                        
                        { label: "equals", value: "=" },
                        { label: "not equal to", value: "!=" },
                        { label: "less than", value: "<" },
                        { label: "greater than", value: ">" },
                        { label: "less or equal", value: "<=" },
                        { label: "greater or equal", value: ">=" },
                        
                        

                    ];
                break;
                case "INT":
                    
                    options = [
                        
                        { label: "equals", value: "=" },
                        { label: "not equal to", value: "!=" },
                        { label: "less than", value: "<" },
                        { label: "greater than", value: ">" },
                        { label: "less or equal", value: "<=" },
                        { label: "greater or equal", value: ">=" }

                    ];
                break;
            default:
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "starts with", value: "like start" },
                    { label: "end with", value: "like end" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" },
                    { label: "contains", value: "like contain" },
                    { label: "does not contain", value: "not like" }
                ];
                break;
        }
    }

    curData.filterOptions = options;
    return curData;
}