/**
 * @Version: 1.0
 * @Author: Frederik
 * @Copyright: 2021 Upeo Consulting
 * @Uses:
 *
 * -----------------------------------------------------------------------------------------------
 * Description: 
 *
 *
 * Created: 18/09/2023
 * Last Updated: 18/09/2023
 *
 * Unit tests:
 *
 * Change log:
 * -----------------------------------------------------------------------------------------------
*/
/**
@Description:

@Change Log:

@Dependencies:

@Test Classes:

*/

public class OdooLoyaltyProgram {

    public List<Data> data;
    public Meta meta;

    public class Data {
        public Integer id;
        public String type;
        public Attributes attributes;
    }

    public class Meta {
        public Integer total;
        public Integer size;
        public Integer limit_x;
        public Integer offset;
    }

    public class Attributes {
        public String name;
        public List<Reward> reward_ids;
    }

    public class Reward {
        public Integer id;
        public String type;
        public RewardAttributes attributes;
    }

    public class RewardAttributes {
        public String name;
        public Decimal point_cost;
        public Decimal minimum_points;
        public Integer reward_product_id;
    }

    public static OdooLoyaltyProgram parse(String json) {
        System.debug('json: ' + json);
        json = json.replace('limit', 'limit_x');
        return (OdooLoyaltyProgram) System.JSON.deserialize(json, OdooLoyaltyProgram.class);
    }

}