@istest(SeeAllData=true)
private class Test_PipelineStageLog_Ctlr
{
    /*(PE3.5, SK, 16Aug2017)
    public static String Pipeline_Stage {public get; public set;}
    */
    
    @isTest(onInstall=True)
    static void testPipControlr1()
    {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Pipeline_Stage_Log__c dumyPip= new Pipeline_Stage_Log__c();
        //  insert dumyPip;
        //string strNameSpace='a021a000001brOW,a021a000001brOW';
        PipelineStageLog_Ctlr Pip_cls= new PipelineStageLog_Ctlr();
        
        Pip_cls.ODViewMode=false;
        Pip_cls.isAdmin=false;
        Pip_cls.strEnableCMTSetup=false;
        Pip_cls.editPipeLineLogSetup();
        Pip_cls.onSavePipeLineLogSetup();
        
        Pip_cls.ODViewMode = true;
        Pip_cls.isAdmin = true;
        
        System.assertEquals(true, Pip_cls.ODViewMode); // (PE3.5, SK, 9Aug2017)
        System.assertEquals(true, Pip_cls.isAdmin); // (PE3.5, SK, 9Aug2017)
        
        Pip_cls.strEnableCMTSetup=true;
        Pip_cls.onSavePipeLineLogSetup();
        
    }
    
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            return;
        }
    }    
}