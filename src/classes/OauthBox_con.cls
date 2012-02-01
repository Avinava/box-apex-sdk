public class OauthBox_con {

    private String auth_token { get; set; }
    private string api_key{get;set;}
    private string ticket{get;set;}
    public Boolean authState{get;set;}
    private Box_Net_Oauth__c token;
    
    public OauthBox_con(){     
         api_key = Label.BoxApiKey;
         auth_token=ApexPages.currentPage().getParameters().get('auth_token');
         ticket=ApexPages.currentPage().getParameters().get('ticket');     
    }
    
    /*
    *Check if the user has already authorized/not
    **/
    public void checkAuthorization(){
        if(auth_token!=null && auth_token!=''){
             revokeAccess();
             insert (new Box_Net_Oauth__c(OwnerId__c=UserInfo.getUserId(),Auth_Token__c=auth_token));
         }
         try{
            token = [SELECT Id FROM Box_Net_Oauth__c WHERE OwnerId__c=:UserInfo.getUserId() ];
            authState=true;
        }
        catch(System.QueryException e){
            authState=false;
        }
    }
  
    /*
    *handles the authorization process, generation of ticket and finally generation of api key
    **/
    public pagereference AuthBox(){
        String response;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.box.net/api/1.0/rest?action=get_ticket&api_key='+api_key );
        req.setMethod('GET');
        
        if(!Test.isRunningTest()){
                 HttpResponse res = h.send(req);
                 response = res.getBody();
        }
        else{	
        		//dummy response for testing
                response='<response><status>get_ticket_ok</status>'+
                                 '<ticket>bxquuv025arztljze2n438md9zef95e8</ticket></response>';
        }
        XmlStreamReader  reader = new XmlStreamReader(response);

            // Read through the XML  
            //and extract the ticket
            while(reader.hasNext()) {
             // System.debug('Event Type:' + reader.getEventType());
              if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()=='ticket') {
                    reader.next();
                   // System.debug('=================='+reader.getText());
                   ticket = reader.getText();
              }
              reader.next();
            }
            if(ticket!=null){
                 
                return new Pagereference(' https://www.box.net/api/1.0/auth/'+ticket+'&test');
            }
      return null;
    }
    
    //delete the access token 
    public void revokeAccess(){
        delete [SELECT Id FROM Box_Net_Oauth__c WHERE OwnerId__c=:UserInfo.getUserId() ];
        authState=false;
    }
}