/**
 * @Version: 1.0
 * @Author: Frederik
 * @Copyright: 2021 Upeo Consulting
 * @Uses:
 * -----------------------------------------------------------------------------------------------
 * Revision No. 	Author 			Date 			Description
 * 1.0 			Frederik 		12/08/2023 		Initial version
 * -----------------------------------------------------------------------------------------------
 * -----------------------------------------------------------------------------------------------
 * Description: Virtual class to handle callouts
 * -----------------------------------------------------------------------------------------------
 * @method: makeCalloutNoBody(Callout callout)
 * @description: Makes a callout without a body
 * @param: Callout callout
 * @return: HttpResponse
 * -----------------------------------------------------------------------------------------------
 * @method: makeCalloutWithBody(Callout callout)
 * @description: Makes a callout with a body
 * @param: Callout callout
 * @return: HttpResponse
 * -----------------------------------------------------------------------------------------------
 * @method: parseHeaders(HttpRequest request, Callout callout)
 * @description: Parses the headers
 * @param: HttpRequest request, Callout callout
 * @return: HttpRequest
 * -----------------------------------------------------------------------------------------------
 * @dependencies: Callout, CalloutValidator
 *
 * Created: 12/08/2023
 * Last Updated: 12/08/2023
 *
 * Unit tests: CalloutHandlerTest
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/

public virtual class CalloutHandler {

    public virtual HttpResponse makeCallout(Callout callout) {
        // Execute the callout

        HttpRequest request = new HttpRequest();
        request.setEndpoint(callout.endpoint);
        request.setMethod(callout.method);
        if(callout.body != null) {
            request.setBody(callout.body);
        }
        // Parse the headers

        if(callout.timeout != null){
            request.setTimeout(Integer.valueOf(callout.timeout));
        }

        if(callout.headers != null) {
            request = parseHeaders(request, callout);
        }

        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response status: ' + response.getStatus());
        return response;
    }

    public virtual HttpRequest parseHeaders(HttpRequest request, Callout callout) {
        // Parse the headers
        for (String header : callout.headers.keySet()) {
            request.setHeader(header, callout.headers.get(header));
        }
        //System.debug('Request: ' + request);
        return request;
    }


}