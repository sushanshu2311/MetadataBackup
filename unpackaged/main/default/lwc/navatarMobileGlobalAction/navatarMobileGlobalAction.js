import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class GlobalButtonsLwc extends NavigationMixin(LightningElement){
    isCallLogOpen = false;

    @api recordId;
    isHomePage = true;
    connectedCallback(){
        if(this.recordId != undefined){
            this.isHomePage = false;
        }
    }
    openLogcallpage(){
        // this.isCallLogOpen = true;
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarNotesMobileLwc",
            attributes: {
            propertyValue: "400",
            taskType : 'Call',
            objectName: 'Task',
            callFromNotification: false,
            openSuggestedTags: false,
            isCalledfromMobile: true,
            isRedirectToParentScreen: true
            }// ,
            // state: { c__taskType : 'Call',
            //         c__objectName: 'Task',
            //         c__callFromNotification: false,
            //         c__openSuggestedTags: false,
            //         c__isCalledfromMobile: true,
            //         c__isRedirectToParent: true
            // }
            }
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/one/one.app#' + encodedCompDef
            }
            });
    }
    openCreateTask(){
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarNotesMobileLwc",
            attributes: {
            propertyValue: "400",
            taskType : '',
            objectName: 'Task',
            callFromNotification: false,
            openSuggestedTags: false,
            isCalledfromMobile: true,
            isRedirectToParentScreen: true
            }
            // ,
            // state: { c__taskType : '',
            //         c__objectName: 'Task',
            //         c__callFromNotification: false,
            //         c__openSuggestedTags: false,
            //         c__isCalledfromMobile: true,
            //         c__isRedirectToParent: true
            // }
            }
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/one/one.app#' + encodedCompDef
            }
            });
    }
    openAddAccount(){
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarCreateMenuFirmLwc",
            attributes: {
            propertyValue: "400",
            }
            }
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/one/one.app#' + encodedCompDef
            }
            });
    }
    openAddContact(){
        var compDefinition = {
            componentDef: "navpeII_dev18:navatarCreateMenuContactLwc",
            attributes: {
            propertyValue: "400",
            }
            }
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/one/one.app#' + encodedCompDef
            }
            });
    }
}