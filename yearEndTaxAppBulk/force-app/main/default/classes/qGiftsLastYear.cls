public class qGiftsLastYear implements Database.Batchable<sObject> {            //,Database.Stateful 
    

    private static final Integer BATCH_SIZE = 20;

    private Integer lastYear = Date.Today().year()-1;

    private static final String HTML_Prefix = '<table style="width:100%; border: 1px solid black;">'  +
        '<tr>' +
            '<th style="border: 1px solid black; padding: 15px;"> Date</th>' +
            '<th style="border: 1px solid black;">Amount</th>' +
        '</tr>';
    private static final String HTML_CELL = '<td style="border: 1px solid black; padding: 15px;">{0}</td>';

    private static final String DATE_FORMAT_STRING = 'MMMM d, yyyy';
    
    @InvocableMethod(description='Year End Tax Flow' )
    public static void yearEndTaxMethod () {
        database.executeBatch(new qGiftsLastYear(), BATCH_SIZE);
    }
    
    /*
    * Query the base set of Contacts to process - filtering for only those with Gifts in the previous year
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Gifts_Last_Year__c 
            FROM Contact 
            WHERE npo02__OppAmountLastYear__c > 0]);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {

        // Retrieve the Opps for the Contacts in scope
        Map<Id, List<Opportunity>> oppsByContact = getOppsByContact(scope);

        // Process each batch of records
        List<Contact> contactsForUpdate = new List<Contact>();

        for (Contact con : scope) {

            String generatedHtml = '';
            for (Opportunity opp : oppsByContact.get(con.Id)) {
                
                Date closeDt = opp.CloseDate;
                Datetime dt = Datetime.newInstance(closeDt.year(), closeDt.month(), closeDt.day());

                String formattedDate = dt.format(DATE_FORMAT_STRING);
                String formattedAmt = String.valueOf(opp.Amount);
                
                generatedHtml +=
                    '<tr>' + 
                        String.format(HTML_CELL, new List<String>{formattedDate}) +
                        String.format(HTML_CELL, new List<String>{formattedAmt}) +
                    '</tr>';
            }

            if (generatedHtml != '') {
                generatedHtml = HTML_Prefix + generatedHtml + '</table>';
                con.Gifts_Last_Year__c = String.escapeSingleQuotes(generatedHtml).left(32768);
                contactsForUpdate.add(con);
            }

            // system.debug('Final String' + finalstring);
        }
        update contactsForUpdate;
       
    }

    public void finish(Database.BatchableContext bc){
        // do nothing here
    }

    /*
    * Retrieve the list of Opportunities by contacts in scope for the previous year
    */
    private Map<Id, List<Opportunity>> getOppsByContact(List<Contact> scope) {

        Set<Id> contactIds = (new Map<Id,Contact>(scope)).keySet();

        Map<Id, List<Opportunity>> oppsByContact = new Map<Id,List<Opportunity>>();
        for (Opportunity opp : [SELECT Id, CloseDate, Amount, npsp__Primary_Contact__c FROM Opportunity
                                WHERE npsp__Primary_Contact__c IN :contactIds
                                AND CALENDAR_YEAR(CloseDate) = :lastYear 
                                AND IsWon = True 
                                ORDER BY npsp__Primary_Contact__c, CloseDate]) {

            if (!oppsByContact.containsKey(opp.npsp__Primary_Contact__c)) {
                oppsByContact.put(opp.npsp__Primary_Contact__c, new List<Opportunity>());
            }
            oppsByContact.get(opp.npsp__Primary_Contact__c).add(opp);
        }

        return oppsByContact;
    }
}