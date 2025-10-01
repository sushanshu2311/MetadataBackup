export default function setFilter({ curData }) {
    /*
       this filter will set the values of allowd filters as per the selected field from the FIELD picklist.
       */
    var fieldType = curData.fDataType.toUpperCase();
    var options = [];
    if (fieldType != '') {
        switch (fieldType) {
            case "MULTIPICKLIST", "EMAIL", "PHONE":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" },
                    { label: "excludes", value: "excludes" },
                    { label: "includes", value: "includes" }
                ];
                break;
            case "BOOLEAN":
                options = [
                    { label: "equals", value: "=" },
                    { label: "not equal to", value: "!=" }
                ];
                break;
            case "DATE", "DOUBLE", "CURRENCY", "PERCENT", "DATETIME":
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
                    { label: "starts with", value: "like" },
                    { label: "less than", value: "<" },
                    { label: "greater than", value: ">" },
                    { label: "less or equal", value: "<=" },
                    { label: "greater or equal", value: ">=" },
                    { label: "contains", value: "contains" },
                    { label: "does not contain", value: "doesnotcontain" }
                ];
                break;
        }
    }

    curData.filterOptions = options;
    return curData;
}