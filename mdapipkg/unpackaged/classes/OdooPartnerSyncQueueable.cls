/**
 * Created by fpardon on 07/09/2023.
 */

public class OdooPartnerSyncQueueable implements Queueable, Database.AllowsCallouts{

    public Integer offset = 0;
    public Integer limiter = 1000;
    public Boolean isSandbox;
    public String environment;
    public String partnerType;

    public OdooPartnerSyncQueueable(Integer offset, Boolean isSandbox, String environment, string partnerType){
        this.offset = offset;
        this.isSandbox = isSandbox;
        this.isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        this.environment = this.isSandbox ? 'Sandbox' : 'Production';
        this.partnerType = partnerType;
    }

    public void execute(QueueableContext context){
        System.debug('OdooPartnerSyncQueueable: ' + this.offset);
        try{
            System.debug('trying to start job');
            syncPartners(offset, limiter);
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }

    public void syncPartners(Integer offset, Integer limiter){
        //Prepare the callout
        System.debug('syncPartners: ' + offset);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:OdooSync/partner'+ '?offset=' + offset + '&limit=' + limiter);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', '8F1vuCBE5cPhaEU5bK3_ZXv53u89gHF-YRp0wJk4SfA');
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = http.send(request);

        //If the response is 200, parse the response and upsert the products
        if(response.getStatusCode() == 200) {
            OdooPartner p = OdooPartner.parse(response.getBody());
            List<OdooPartner.Data> partnerData = p.data;
            System.debug('partnerData: ' + partnerData);
            Map<Integer,String> resultMap = OdooPartnerService.parsePartnerToAccount(partnerData, this.partnerType);
            System.debug('resultMap: ' + resultMap);
            OdooPartner.Meta meta = p.meta;
            if(meta.offset + meta.limit_x < meta.total){
                system.debug('meta.offset: ' + meta.offset);
                system.debug('meta.limit_x: ' + meta.limit_x);
                system.debug('meta.total: ' + meta.total);
                OdooPartnerSyncQueueable sync = new OdooPartnerSyncQueueable(meta.offset + this.limiter, this.isSandbox, this.environment, this.partnerType);
                System.enqueueJob(sync);
            }
        } else {
            System.debug('Error: ' + response.getBody());
        }
    }

}