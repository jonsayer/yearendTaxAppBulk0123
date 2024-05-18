// Code by Jessie Rymph: https://github.com/forcethesales/yearendTaxAppBulk0123
// Updated by Jon Sayer of Data Geeks Lab: jon@datageekslab.com

// This class is the main utility for the application. 
// Changes made by Jon Sayer from Jessie's original: 
// 	- Use of custom labels for the styling text and HTML to allow for changes to styling without code deployments.
// 	- Use of custom metadata for the SOQL query filter, to allow for wider functionality


public class qGiftsLastYear implements Database.Batchable<sObject> {            //,Database.Stateful 
    

    private static final Integer BATCH_SIZE = 20;

    private Integer lastYear = Date.Today().year()-1;

    private static final String HTML_Prefix 	= Label.HTML_Table_Prefix;
    private static final String HTML_CELL 		= Label.HTML_Table_Cell;
    private static final String HTML_ROW_START 	= Label.HTML_Table_Row_Start;
    private static final String HTML_ROW_END 	= Label.HTML_Table_Row_End;
    private static final String HTML_Suffix 	= Label.HTML_Table_Suffix;
    private static final String CURRENCY_SYMBOL = Label.Currency_Symbol;

    private static final String DATE_FORMAT_STRING = Label.Date_Format_String;
    
    private static string contactWHERE(){
        if(Test.isRunningTest() ){
            return ' npo02__OppAmountLastYear__c > 0 ';
        } else {
            Tax_Letter_Summary_Table_Setting__mdt settings = Tax_Letter_Summary_Table_Setting__mdt.getInstance('Default'); 
            return settings.Contact_Filter__c;
        }
    }

    private static string oppWHERE(){
        if( Test.isRunningTest() ){
            return ' AND CALENDAR_YEAR(CloseDate) = :lastYear AND IsWon = True ';
        } else {
            Tax_Letter_Summary_Table_Setting__mdt settings = Tax_Letter_Summary_Table_Setting__mdt.getInstance('Default'); 
            return settings.Opportunity_Filter__c;
        }
    }
    
    @InvocableMethod(description='Year End Tax Flow' )
    public static void yearEndTaxMethod () {
        database.executeBatch(new qGiftsLastYear(), BATCH_SIZE);
    }
    
    /*
    * Query the base set of Contacts to process - filtering for only those with Gifts in the previous year
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStart   = ' SELECT Id, Gifts_Last_Year__c FROM Contact WHERE ';
        String whereClaus2  = contactWHERE();
        String queryEnd		= '';
        return Database.getQueryLocator(queryStart + whereClaus2 + queryEnd);
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
                String formattedAmt = CURRENCY_SYMBOL + String.valueOf(opp.Amount);
                
                generatedHtml +=
                    HTML_ROW_START + 
                        String.format(HTML_CELL, new List<String>{formattedDate}) +
                        String.format(HTML_CELL, new List<String>{formattedAmt}) +
                    HTML_ROW_END;
            }

            if (generatedHtml != '') {
                generatedHtml = HTML_Prefix + generatedHtml + HTML_Suffix;
                con.Gifts_Last_Year__c = String.escapeSingleQuotes(generatedHtml).left(32768);
                contactsForUpdate.add(con);
            }
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
        String queryStart   = ' SELECT Id, CloseDate, Amount, npsp__Primary_Contact__c FROM Opportunity WHERE npsp__Primary_Contact__c IN :contactIds ';
        String whereClaus2  = oppWHERE();
        String queryEnd		= ' ORDER BY npsp__Primary_Contact__c, CloseDate ';
        
        for (Opportunity opp : Database.query(queryStart + whereClaus2 + queryEnd)) {

            if (!oppsByContact.containsKey(opp.npsp__Primary_Contact__c)) {
                oppsByContact.put(opp.npsp__Primary_Contact__c, new List<Opportunity>());
            }
            oppsByContact.get(opp.npsp__Primary_Contact__c).add(opp);
        }

        return oppsByContact;
    }
        
}