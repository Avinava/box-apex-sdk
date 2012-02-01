@isTest(OnInstall=true)
private class Test_BoxToolKit{
    static testMethod void test_BoxToolKit(){
        List<Box_Net_Oauth__c> allAuth = [SELECT Id FROM Box_Net_Oauth__c WHERE OwnerId__c=:UserInfo.getUserId()];
        if(allAuth.isEmpty()){
            Box_Net_Oauth__c boxAuth=new Box_Net_Oauth__c(Auth_Token__c='testAuthKey',OwnerId__c=UserInfo.getUserId());
            insert boxAuth;
        }
        Document doc=new Document(Name='test',Type='txt',ContentType='text/plain',Body=Blob.valueOf('someBlob'),FolderId =UserInfo.getUserId() );
        insert doc;
        Test.startTest();
        String dummyString = 'Dummy';
        List<String> emails = new List<String>();
        emails.add('dummy@dummytest.com');
        BoxToolKit box = new BoxToolKit();
        box.getFolderTree(dummyString);
        box.getFullFolderTree(dummyString);
        box.createNewFolder(dummyString,dummyString,dummyString);
        box.Rename(dummyString,dummyString,dummyString);
        box.Delete_x(dummyString,dummyString);
        box.move(dummyString,dummyString,dummyString);
        
        box.privateShare(dummyString,dummyString,emails,dummyString,dummyString);
        box.publicShare(dummyString,dummyString,emails,dummyString,dummyString);
        box.privateShare(dummyString,dummyString,new List<String>(),dummyString,dummyString);
        box.publicShare(dummyString,dummyString,new List<String>(),dummyString,dummyString);
        
        box.publicUnshare(dummyString,dummyString);
        box.getVersions(dummyString);
        box.makeCurrentVersion(dummyString);
        box.getFileInfo(dummyString);
        box.setDescription(dummyString,dummyString,dummyString);
        box.downloadAsDocument(dummyString);
        box.uploadDocumentById(doc.Id+'',dummyString,dummyString);
        box.uploadDocument(new Document(Name='test',Type='txt',ContentType='text/plain',Body=Blob.valueOf('someBlob')),dummyString,dummyString);
        box.registerNewUser(dummyString,dummyString);
        box.getCollaborations(dummyString);
        box.getCollaborationsLink(dummyString);
        box.requestFriends(emails,dummyString,true,true);
        box.getFriends();
        box.getContacts();
        box.getUserId(dummyString);
        box.getUserInfo(dummyString);
        Test.stopTest();
    }
    
    static testMethod void test_BoxToolKit_exception(){
        try{
            List<Box_Net_Oauth__c> allAuth = [SELECT Id FROM Box_Net_Oauth__c WHERE OwnerId__c=:UserInfo.getUserId()];
            if(!allAuth.isEmpty()) delete allAuth ;
            BoxToolKit box = new BoxToolKit();
        }
        catch(Exception e){
        
        }
    }
    
    static testmethod void test_OauthBox_con(){
        Box_Net_Oauth__c boxAuth=new Box_Net_Oauth__c(Auth_Token__c='testAuthKey',OwnerId__c=UserInfo.getUserId());
        insert boxAuth;
        Test.setCurrentPage(Page.Oauth_box);
        System.currentPagereference().getParameters().put('auth_token','auth_token');
        System.currentPagereference().getParameters().put('ticket','ticket');
        OauthBox_con controller = new OauthBox_con();
        controller.checkAuthorization();
        System.assertEquals(true,controller.authState);
        controller.AuthBox();
    }
    
     static testmethod void test_OauthBox_con2(){
          List<Box_Net_Oauth__c> allAuth = [SELECT Id FROM Box_Net_Oauth__c WHERE OwnerId__c=:UserInfo.getUserId()];
          if(!allAuth.isEmpty()) delete allAuth ;
          Test.setCurrentPage(Page.Oauth_box);
          OauthBox_con controller = new OauthBox_con();
          controller.checkAuthorization();
     }

}