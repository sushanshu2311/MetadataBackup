import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // To display toast

// Validates advance filter logic
export function validateAdvanceFilterLogic(filterData, filterLogicVal) {
    let indexesInFilterVal = [];
    let result = { filterErrMsg: '', finalFilterList: [] };
    let isValid = true;
    result.finalFilterList = formatFilterStr(filterLogicVal);
    indexesInFilterVal = result.finalFilterList.filter(isNumber);

    for (let i = 0; i < indexesInFilterVal.length; i++) {
        if (i >= 0 && i < filterData.length) {
            if (filterData[i].field != "") {
                isValid = true;
            }
            else {
                isValid = false;
                result.filterErrMsg = "The filter logic references an undefined filter: " + indexesInFilterVal[i] + ".";
            }
        }
        else {
            isValid = false;
            result.filterErrMsg = "The filter logic references an undefined filter: " + indexesInFilterVal[i] + ".";
        }
    }
    //Added if condition by Lakshya on 2021-12-17 to resolve 00030335
    if(indexesInFilterVal.length < filterData.length){
        isValid = false;
    }
    if (result.filterErrMsg == "") {
        if (isValid) {
            if (!callSubstrCheck(filterLogicVal)) {
                result.filterErrMsg = "Your filter logic is imprecise or incorrect.Please use correct format for filter logic. \ne.g.- 1 AND 2, 1 OR 2, (1 OR 2) AND 3 etc.";
            }
        }
        else {
            isValid = callSubstrCheck(filterLogicVal);
            if (isValid) {
                //Replaced </br> with \n to break line by Lakshya on 2021-12-17 to resolve 00030335
                result.filterErrMsg = "Some filter conditions are defined but not referenced in your filter logic.\nPlease review all the filters in your filter logic.";
            }
            else {
                filterErrMsg = "Your filter logic is imprecise or incorrect. Please use correct format for filter logic.</br>  e.g.- 1 AND 2 , 1 OR 2, (1 OR 2) AND 3 etc.";
            }
        }
    }
    return result;
}

//Formats the entered advance filter string so that it can be validated further
const formatFilterStr = (filtertst) => {
    let filtr = new Array();
    let finalfiltr = new Array();
    let requireddata = new Array();

    for (let i = 1; i <= 10; i++)
        requireddata.push('' + i);

    requireddata.push('and');
    requireddata.push('not');
    requireddata.push('or');
    requireddata.push('(');
    requireddata.push(')');

    filtertst = filtertst.toLowerCase();
    //Modified by Lakshya on 2021-12-17 to resolve 00030294
    //Replaced "replace" with "replaceAll" to replace all instances of the mentioned string
    filtertst = filtertst.replaceAll('(', ' ( ').replaceAll(')', ' ) ').replaceAll('and', ' and ').replaceAll('or', ' or ').replaceAll('not', ' not ');
    filtr = filtertst.split(' ');
    for (let i = 0; i < filtr.length; i++) {
        if (requireddata.includes(filtr[i])) {
            finalfiltr.push(filtr[i]);
        }
    }
    return finalfiltr;
}

const callSubstrCheck = (filtrstrtotest) => {
    let status = true;
    let filterstrng = filtrstrtotest.toLowerCase();
    let trmfilterstrng = filtrstrtotest.toLowerCase().replace(/\(/gi, "").replace(/\)/gi, "");
    let chckparan = filtrstrtotest.toLowerCase();

    status = checkfilterlogicfrParenthesis(filterstrng);
    trmfilterstrng = trmfilterstrng.trim();
    filterstrng = '(' + filterstrng + ')';

    if (status == true) {
        if (trmfilterstrng.length > 1 && (trmfilterstrng != '10')) {
            status = substrcheck(filterstrng);
        }
        else if (trmfilterstrng == '1' || trmfilterstrng == '2' || trmfilterstrng == '3' || trmfilterstrng == '4' || trmfilterstrng == '5' || trmfilterstrng == '6' || trmfilterstrng == '7' || trmfilterstrng == '8' || trmfilterstrng == '9' || trmfilterstrng == '10' || (trmfilterstrng.length == 0 && chckparan.search(/\(/gi) == -1 && chckparan.search(/\)/gi) == -1)) {
            status = true;
        }
        else {
            status = false;
        }
    }
    return status;
}
//Checks if input is number or not
const isNumber = (n) => {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

//For showing error on UI
export function showNotification(_title, message, variant) {
    const evt = new ShowToastEvent({
        title: _title,
        message: message,
        variant: variant,
        mode: variant == 'error' ? 'sticky' : 'pester'
    });
    return evt;
}

const checkfilterlogicfrParenthesis = (filterstr) => {
    let str = filterstr.toLowerCase();
    let paranthesesck = new Array();
    let status = true;

    for (let i = 0; i < str.length; i++) {
        if (str.charAt(i) == '(') {
            paranthesesck.push(str.charAt(i));
        }
        if (str.charAt(i) == ')') {
            if (paranthesesck.length > 0) {
                paranthesesck.pop();
            }
            else {
                status = false;
                break;
            }
        }
    }
    if (paranthesesck.length > 0 || status == false) {
        status = false;
    }
    else {
    }
    return status;
};

const substrcheck = (chckstr) => {
    let str = chckstr;
    let clseindx;
    let opnindx;

    for (let i = 0; i < str.length; i++) {
        if (str.charAt(i) == ')') {
            clseindx = i;
            break;
        }
    }
    for (let j = clseindx; j >= 0; j--) {
        if (str.charAt(j) == '(') {
            opnindx = j;
            break;
        }
    }

    let substr = str.substring(j + 1, i);
    let starstr = str.substring(0, j);
    let endrstr = str.substring(i + 1);
    let stat = true;

    if (substr.trim().length == 0) {
        stat = false;
    }
    if (stat == true && substr != ' 1 ') {
        stat = checkfilterwithoutparentheses(substr);
    }
    if (stat == true) {
        let nwstr1 = starstr + ' 1 ' + endrstr;

        if (nwstr1 != ' 1 ') {
            stat = substrcheck(nwstr1);
        }
        else {
            stat = true;
        }
    }
    else {
        stat = false;
    }
    return stat;
};

const checkfilterwithoutparentheses = (strtotest) => {
    let nwstr = strtotest;
    let strarry = new Array();
    let finalstrarry = new Array();
    let status = true;
    let l = 0;

    strarry = nwstr.split(' ');

    for (let k = 0; k < strarry.length; k++) {
        if (strarry[k] == '1' || strarry[k] == '2' || strarry[k] == '3' || strarry[k] == '4' || strarry[k] == '5' ||
            strarry[k] == '6' || strarry[k] == '7' || strarry[k] == '8' || strarry[k] == '9' || strarry[k] == '10') {
            finalstrarry[l] = 'number';
            l++;
        }
        else if (strarry[k] == 'and' || strarry[k] == 'or') {
            finalstrarry[l] = 'operator';
            l++;
        }
        else if (strarry[k] == 'not') {
            finalstrarry[l] = 'not';
            l++;
        }
        else if (strarry[k] == '(' || strarry[k] == ')' || strarry[k].trim().length == 0) // Make Use Of Trim Here
        {
        }
        else {
            status = false;
            break;
        }
    }
    if (status == false) {
    }
    else {
        for (let m = 0; m < finalstrarry.length; m++) {
            if (m > 0 && m < finalstrarry.length - 1) {
                if (finalstrarry[m] == 'number' && finalstrarry[m + 1] == 'operator' && (finalstrarry[m - 1] == 'not' || finalstrarry[m - 1] == 'operator')) {
                    status = true;
                }
                else if (finalstrarry[m] == 'operator' && finalstrarry[m - 1] == 'number' && (finalstrarry[m + 1] == 'not' || finalstrarry[m + 1] == 'number')) {
                    status = true;
                }
                else if (finalstrarry[m] == 'not' && (finalstrarry[m - 1] == 'not' || finalstrarry[m - 1] == 'operator') && (finalstrarry[m + 1] == 'number' || finalstrarry[m + 1] == 'not')) {
                    status = true;
                }
                else {
                    status = false;
                    break;
                }
            }
            else if (m == 0) {
                if (finalstrarry[m] == 'number' && finalstrarry[m + 1] == 'operator') {
                    status = true;
                }
                else if (finalstrarry[m] == 'operator') {
                    status = false;
                    break;
                }
                else if (finalstrarry[m] == 'not' && (finalstrarry[m + 1] == 'number' || finalstrarry[m + 1] == 'not')) {
                    status = true;
                }
                else {
                    status = false;
                    break;
                }
            }
            else if (m == finalstrarry.length - 1) {
                if (finalstrarry[m] == 'number' && (finalstrarry[m - 1] == 'not' || finalstrarry[m - 1] == 'operator')) {
                    status = true;
                }
                else if (finalstrarry[m] == 'operator') {
                    status = false;
                    break;
                }
                else if (finalstrarry[m] == 'not') {
                    status = false;
                    break;
                }
                else {
                    status = false;
                    break;
                }
            }
        }
    }
    return status;
};