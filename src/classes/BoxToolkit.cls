/*
*	Author : Avinava Maiti(avinavamaiti@gmail.com)
*	Description : This class provides wrapper methods to invoke the Box.net
*					REST API. Provides method for downloading,uploading,collaboration
*					contactinfo,adding new user and many more
*	NOTE: All the method included here return the result as XML for details please check box.com/developers		
**/
public class BoxToolkit{
   
    private String apiKey,authToken,authorizationStr;
    private static final String BOX_ACTION_ENDPOINT='https://www.box.net/api/1.0/rest?action=';
    private static final String BOX_UPLOAD_ENDPOINT='http://upload.box.net/api/1.0/';
    private static final String BOX_DOWNLOAD_ENDPOINT='https://www.box.net/api/1.0/download/';
    
    public class oAuthException extends Exception {}
    
    public BoxToolkit(){
            Box_Net_Oauth__c boxAuth = new Box_Net_Oauth__c();
            try{
            	//get the auth token fro the current user
	            boxAuth = [SELECT Id, Auth_Token__c FROM Box_Net_Oauth__c WHERE OwnerId__c=:UserInfo.getUserId()];
	            if(!Test.isRunningTest()){
	            	//get the api key from custom setting
	            	apiKey = BoxConnection__c.getValues('Box.net').Api_Key__c;
	            }
	            else{
	            	apiKey = 'someSampleTestValue';
	            }
	            authToken = boxAuth.Auth_Token__c;
	            authorizationStr = '&api_key='+apiKey+'&auth_token='+authToken;
            }
            catch(System.QueryException e){
            	throw new oAuthException('User has not authorized yet. Please go to the authorization page for authorization.');
            }
        }
        
    /* 
    *This method gives the folder tree of the account starting from the specified FolderId passed as parameter
    *----------------------------------------Parameters-------------------------------------------------------
    *   1.sFolderId = Box.net Id of the folder from where the mapping need to be done
    *                 Pass sFolderId as "0" if you want to get the entire accounts folder tree
    *----------------------------------------------------------------------------------------------------------
    ***/    
    public String getFolderTree(String sFolderId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_account_tree'+authorizationStr+'&folder_id='+sFolderId+'&params[]=nozip&params[]=nofiles&params[]=simple';
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method returns the full Folder tree including the files from the specified sFolderId
    *----------------------------------------Parameters-------------------------------------------------------
    *   1.sFolderId = Box.net Id of the folder from where the mapping need to be done
    *                 Pass sFolderId as "0" if you want to get the entire accounts folder tree
    *----------------------------------------------------------------------------------------------------------
    ***/
    public String getFullFolderTree(String sFolderId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_account_tree'+authorizationStr+'&folder_id='+sFolderId+'&params[]=nozip&params[]=simple';
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method creates a new folder with folder name "folderName" inside the parent folder whose Id is parentFolderId
    *-------------------------------------------Parameters-------------------------------------------------------------
    *   1.folderName : The name of the new folder
    *   2.parentFolderId : Box.net Id of the folder where the folder needs to be created
    *                      Pass sFolderId as "0" if you want to get the create the folder in root folder
    *	3.share : A binary parameter which can be set to 1 in order to allow the folder to be shared.
    *------------------------------------------------------------------------------------------------------------------
    ***/
    public String createNewFolder(String folderName,String parentFolderId,String share){
    	folderName = Encodingutil.urlEncode(folderName, 'UTF-8');
        String sUrl = BOX_ACTION_ENDPOINT+'create_folder'+authorizationStr+'&parent_id=0&name='+folderName+'&share='+share;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    
    /*
    *This method is used to RENAME a folder/file
    *--------------------Parameters-----------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.targetId :  box.net id of folder/file to rename
    *   3.newName : new name of the folder/file
    *-----------------------------------------------------------------------------------------------------------------
    ***/
    public String Rename(String targetType,String targetId,String newName){
        String sUrl =BOX_ACTION_ENDPOINT+'rename'+authorizationStr+'&target='+targetType+'&target_id='+targetId+'&new_name='+newName;
        
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to DELETE a file/folder
    *--------------------Parameters---------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.targetId :  box.net id of folder/file to delete
    *---------------------------------------------------------------------------------------------------------------
    ***/
    public String Delete_x(String targetType,String targetId){
        String sUrl = BOX_ACTION_ENDPOINT+'delete'+authorizationStr+'&target='+targetType+'&target_id='+targetId;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to MOVE a folder/file
    *--------------------Parameters---------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.sourceId :  box.net id of folder/file box.net id to move
    *   3.destinationId : destination folder Id
    *---------------------------------------------------------------------------------------------------------------
    ***/
    public String Move(String targetType,String sourceId,String destinationId){
        String sUrl = BOX_ACTION_ENDPOINT+'move'+authorizationStr+'&target='+targetType+'&target_id='+sourceId+'&destination_id='+destinationId;
                      
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
        
    }
    
    
    /*
    *This method privately shares a file or folder with another user(s).
    *--------------------Parameters-----------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.targetId :  box.net id of folder/file to share
    *   3.emails : list of emails of user to share the folder with
    *   4.notify : Valid values are "0" and "1" if the value is "1" then send emails
    *   5.message : message to send via email
    *------------------------------------------------------------------------------------------------------------------
    ***/
    public String privateShare(String targetType,String targetId,List<String> emails,String message,String notify){
        String emailParam='';
        for(String email:emails){
            emailParam = '&emails[]='+email;
        }
        emailParam = Encodingutil.urlEncode(emailParam, 'UTF-8');
        String sUrl = BOX_ACTION_ENDPOINT+'private_share'+authorizationStr+'&target='+targetType+'&target_id='+targetId+'&notify='+notify+emailParam+'&message='+message;
        
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    
    /*
    *This method makes a file or folder shareable, and may initiate sharing through Box email notifications
    *--------------------Parameters-------------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.targetId :  box.net id of folder/file to share
    *   3.emails : list of emails of user to share the folder with
    *   4.message : message to send via email
    *   5.password : password to protect the file
    *-------------------------------------------------------------------------------------------------------------------
    ***/
    public String publicShare(String targetType,String targetId,List<String> emails,String message,String password){
        String emailParam='';
        for(String email:emails){
            emailParam = '&emails[]='+email;
        }
        if(emailParam==''){
            emailParam='&emails[]=';
        }
        emailParam = Encodingutil.urlEncode(emailParam, 'UTF-8');
        String sUrl = BOX_ACTION_ENDPOINT+'private_share'+authorizationStr+'&target='+targetType+'&target_id='+targetId+'&message='+message+emailParam+'&password='+password;
        
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method unshares file or folder previously shared
    *--------------------Parameters------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.targetId :  box.net id of folder/file to unshare
    *------------------------------------------------------------------------------------------------------------
    **/
    public String publicUnshare(String targetType,String targetId){
        String sUrl = BOX_ACTION_ENDPOINT+'public_unshare'+authorizationStr+'&target='+targetType+'&target_id='+targetId;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to retrieve the past versions of a file.
    *--------------------Parameters------------------------------------------------------------------------------
    *   1.targetId :  box.net id of folder/file currently box.net
    *------------------------------------------------------------------------------------------------------------
    ***/
    public String getVersions(String targetId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_versions'+authorizationStr+'&target=file&target_id='+targetId;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to set a past version of a file as the current version.
    --------------------Parameters---------------------------------------------------------------
    *	1.versionid = The id of the item version that you would like to set as current
    *---------------------------------------------------------------------------------------------
    ****/
    public String makeCurrentVersion(String versionid){
        String sUrl = BOX_ACTION_ENDPOINT+'make_current_version'+authorizationStr+'&version_id='+versionid;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method retrieves the details for a specified file.
    *--------------------Parameters---------------------------------------------------------------
    *	1.fileId = Box.net id of file for which detail is required 
    *---------------------------------------------------------------------------------------------
    ***/
    public String getFileInfo(String fileId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_file_info'+authorizationStr+'&file_id='+fileId;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method sets the description for a file or folder.
    *--------------------Parameters------------------------------------------------------------------------------
    *   1.tagetType : "folder" and "file" are only valid values
    *   2.targetId :  box.net id of folder/file 
    *	3.description : Description to be set for the file/folder
    *------------------------------------------------------------------------------------------------------------
    ***/
    public String setDescription(String targetType,String targetId,String description){
        String sUrl = BOX_ACTION_ENDPOINT+'set_description'+authorizationStr+'&target='+targetType+'&target_id='+targetId+'&description='+description;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to register a new user with a free personal account.
    *--------------------Parameters------------------------------------------------------------------------------
    *	1.login : The login username for the user you intend to create.
	*	2.password	: The login password for the user you intend to create.
    *------------------------------------------------------------------------------------------------------------
    ***/
    public String registerNewUser(String login,String password){
        String sUrl = BOX_ACTION_ENDPOINT+'register_new_user'+authorizationStr+'&login='+login+'&password='+password;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to obtain a list of collaborators for folder
    *--------------------Parameters------------------------------------------------------------------------------
    *	1.targetId :  box.net id of folder 
    *------------------------------------------------------------------------------------------------------------
    ***/
    public String getCollaborations(String folderId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_collaborations'+authorizationStr+'&target=folder&target_id='+folderId;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This function is used to invite collaborators to  a folder.
    *--------------------Parameters------------------------------------------------------------------------------
    *	1.targetId :  box.net id of folder 
    *------------------------------------------------------------------------------------------------------------
    ***/
    public String getCollaborationsLink(String folderId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_collaboration_link'+authorizationStr+'&target=folder&target_id='+folderId;
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method requests new friends to be added to the user's network.
    *--------------------Parameters------------------------------------------------------------------------------
    *	1.emails : An array of emails for which to notify users about the newly shared file or folder.
    *	2.message : An message to be included in a notification email.
    *	3.autoSubscribe : Subscribe to the public boxes of invited users, if the value is set true.
    *	4.noEmail : Do not send emails to the invited users,if the value is set true
    *------------------------------------------------------------------------------------------------------------
    ***/ 
    public String requestFriends(List<String> emails,String message,Boolean autoSubscribe,Boolean noEmail){
        String emailParam='',params;
        for(String email:emails){
            emailParam = '&emails[]='+email;
        }
        if(emailParam==''){
            emailParam='&emails[]=';
        }
        if(autoSubscribe){
        	params = '&params[]=auto_subscribe';
        }
        if(noEmail){
        	params = params+'&params[]=no_email';
        }
        emailParam = Encodingutil.urlEncode(emailParam, 'UTF-8');
        String sUrl = BOX_ACTION_ENDPOINT+'request_friends&message='+message+emailParam+params;
        
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to retrieve a list of the user's friends.
    ***/
    public String getFriends(){
        String sUrl = BOX_ACTION_ENDPOINT+'get_friends'+authorizationStr+'&params[]=nozip';
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to retrieve a list of the user's contacts (all users with whom the user has shared content or collaborated on content).
    ***/
    public String getContacts(){
        String sUrl = BOX_ACTION_ENDPOINT+'get_contacts'+authorizationStr+'&params[]=nozip';
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This function is used to obtain a given userid when the user's login email is available.
    *--------------------Parameters--------------------------------------------------------------------------------------
    *	1.loginEmail : login id of the user
    *--------------------------------------------------------------------------------------------------------------------
    ***/
    public String getUserId(String loginEmail){
        String sUrl = BOX_ACTION_ENDPOINT+'get_user_id'+authorizationStr+'&login='+loginEmail+'&params[]=';
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This function is used to obtain profile information for a user in one's contact list
    *--------------------Parameters--------------------------------------------------------------------------------------
    *	1.userId : userId of the user
    *--------------------------------------------------------------------------------------------------------------------
    ***/
    public String getUserInfo(String userId){
        String sUrl = BOX_ACTION_ENDPOINT+'get_user_info'+authorizationStr+'&user_id='+userId+'&params[]=show_collab_items';
        HttpResponse res=executeGet(sUrl);
        return res.getBody();
    }
    
    /*
    *This method is used to download a file from box.net account
    *returns a Document object of the specified "fileId"
    *--------------------Parameters--------------------------------------------------------------------------------------
    *   1.fileId : box.net Id of file to download
    *--------------------------------------------------------------------------------------------------------------------
    **/
    public Document downloadAsDocument(String fileId){
    	Blob body;
    	String sFilename='';
        String sUrl = BOX_DOWNLOAD_ENDPOINT+authToken+'/'+fileId;
        HttpResponse res=executeGet(sUrl);
        //extracting the field name and extension
        if(!Test.isRunningTest()){
	        List<String> contentInfo =res.getHeader('Content-Disposition').split(';',-1);
	        sFilename = contentInfo[1].substring(contentInfo[1].indexOf('"')+1,contentInfo[1].lastIndexOf('"'));
	        body= Encodingutil.base64Decode(res.getBody());
        }
        Document mydoc = new Document();
        mydoc.Body =body;      
        mydoc.Name=sFilename;   
        return mydoc;
    }
    
    
    /*
    *This method UPLOADS the specified document from Salesforce's Document object 
    *--------------------Parameters-----------------------------------------------------------------------------------
    *   1.sDocumentId : Salesforce Id of the document to be uploaded
    *   2.sFolderId : Box.net Id of the folder where the new file need to be uploaded
    *   3.sActionType : Type of action valid values are "upload", "overwrite" and "new_copy"
    *-----------------------------------------------------------------------------------------------------------------
    *   NOTE:The files uploaded from salesforce.com when directly  downloaded box.net  will be corrupted
    *-----------------------------------------------------------------------------------------------------------------
    **/
    public String uploadDocumentById(String sDocumentId,String sFolderId,String sActionType){
        Document doc = [SELECT  Body, BodyLength, Id, Name, Type, ContentType FROM Document WHERE Id =:sDocumentId];
        String sUrl = BOX_UPLOAD_ENDPOINT+sActionType+'/'+authToken+'/'+sFolderId;
        HttpResponse res =executePost(sUrl,doc);
        return res.getBody();
    }
    
    
    /*
    *This method UPLOADS a Document object into Box.net account
    *--------------------Parameters------------------------------------------------------------------------
    *   1.doc : Document obj with  Name,Type(extension),Content Type,Body 
    *   2.sFolderId : Box.net Id of the folder where the new file need to be uploaded
    *   3.sActionType : Type of action valid values are "upload", "overwrite" and "new_copy"
    *------------------------------------------------------------------------------------------------------
    *-------------------------------------------------------------------------------------------------------
    *   NOTE:The files uploaded from salesforce.com when directly  downloaded box.net  will be corrupted
    *-------------------------------------------------------------------------------------------------------
    **/
    public String uploadDocument(Document doc,String sFolderId,String sActionType){
        //Document doc = [SELECT  Body, BodyLength, Id, Name, Type, ContentType FROM Document WHERE Id =:sDocumentId];
        String sUrl = BOX_UPLOAD_ENDPOINT+sActionType+'/'+authToken+'/'+sFolderId;
        HttpResponse res =executePost(sUrl,doc);
        return res.getBody();
    }
    
    /*
    *This method executes any get request and returns the response
    */
    private HttpResponse executeGet(String sUrl){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sUrl);
        req.setMethod('GET');
        HttpResponse res;
        if(!Test.isRunningTest()){
        	res = h.send(req);
        }
        else{
        	 res = new HttpResponse();
        }
        return res;
    }
    
    /*
    *This method  handles the uploading of document to box.net account
    **/
    private HttpResponse executePost(String sUrl,Document doc){
        String p_fileName =doc.Name+'.'+doc.Type;
        String boundary = 'AaBbCcX30';
        System.debug(doc);
        String content = 'Content:\r\n--' + boundary + '\r\nContent-Disposition:attachment;name="' + p_fileName + 
                        '";filename="'+p_fileName+'"\r\n';
        content +='Content-Type: '+doc.ContentType+'\r\n';
        content +='Content-Transfer-Encoding: base64\r\n\r\n';
        content += EncodingUtil.base64Encode(doc.Body)+'\r\n\r\n';
        content += '--'+boundary+'--\r\n';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','multipart/form-data;boundary='+boundary);
        req.setHeader('Content-Encoding','base64');
        req.setEndpoint(sUrl);
        req.setMethod('POST');
        req.setBody(content);
        HttpResponse res;
        if(!Test.isRunningTest()){
        	res = h.send(req);
        }
        else{
        	 res = new HttpResponse();
        }
        return res;
    }

}