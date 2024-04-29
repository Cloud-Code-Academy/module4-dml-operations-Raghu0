/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Raghava
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account();

        // Set some fields on the Account
        acc.Name = 'Cloud Code Academy';
        acc.Active__c = 'Yes';

        // Insert the Account into the database
        insert acc;

        // Return the Id of the newly created Account
        return acc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        ACcount acc = new Account();
        acc.Name = name;
        acc.Industry = industry;
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact cont = new Contact();
        // Set some fields on the Contact
        cont.FirstName = 'Shane';
        cont.LastName = 'Warne';
        // Set the AccountId field to the given accountId
        cont.AccountId = accountId;

        // Insert the Contact into the database
        insert cont;

        // Return the Id of the newly created Contact
        return cont.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact cont = [SELECT Id FROM Contact WHERE Id = :contactId];

        // Update the Contact's last name
        cont.LastName = newLastName;
        // Update the Contact in the database
        update cont;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];

        // Update the Opportunity's stage
        opp.StageName = newStage;

        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        List<Account> acc = [SELECT Id FROM Account WHERE Id = :accountId];

        // Update the Account with the given Id with the new name and industry
        acc[0].Name = newName;
        acc[0].Industry = newIndustry;
        update acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Iterate over the opportunities
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
            List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
            for(Opportunity opp : opportunities){
                opp.StageName = 'Qualification';
                opp.CloseDate = Date.today().addMonths(3);
                opp.Amount = 50000;
                oppsToBeUpdated.add(opp);
            }

        // Upsert the Opportunity
        upsert oppsToBeUpdated;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {

        List<Account> accts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Account acc;
        if(accts.isEmpty()){
            acc = new Account(Name = accountName);
            insert acc;
        }
        else {
            acc = accts[0];
        }
        
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        for(Opportunity opp : [SELECT Id, AccountId, Name FROM Opportunity WHERE Name IN : oppNames]){
            oppMap.put(opp.Name, opp);
        }
        List<Opportunity> oppsToUpsert = new List<Opportunity>();
        for(String oppName : oppNames){
            Opportunity opp = oppMap.get(oppName);
            if(opp == null){
                opp = new Opportunity (
                    Name = oppName,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addMonths(2)
                );
            } else if (opp.AccountId != acc.Id){
                opp.AccountId = acc.Id;
            }
            oppsToUpsert.add(opp);
        }
        upsert oppsToUpsert;
    }

        /*
        List<Opportunity> oppsToBeCreated = new List<Opportunity>();
        // Loop through each Opportunity name
        for(String oppName : oppNames){
            // Create an Opportunity with the given name
            Opportunity opp = new Opportunity();
            opp.Name = oppName;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today().addMonths(2);
            // Add the Opportunity to the list
            oppsToBeCreated.add(opp);
        }
        insert oppsToBeCreated;

            List<Account> acc = [SELECT Id, Name FROM Account WHERE Name = :accountName];
            Account newAccount = new Account();
            if(acc.isEmpty()){
                newAccount.Name = accountName; 
                insert newAccount;
            }
            for(Opportunity opp : oppsToBeCreated){
                opp.AccountId = newAccount.Id;
            }
        upsert oppsToBeCreated;
    }*/
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */

     
	public static Account upsertAccount(String accountName) {
        Account acc = new Account();
        // Query for the Account
            List<Account> account = [SELECT Id, Name, Description FROM Account WHERE Name = :accountName];
            // if the Account exists, update the description
            if(!account.isEmpty()){
                acc = account[0];
                acc.Description = 'Updated Account';
            }
            // otherwise, create a new Account and set the description
            else{
                acc.Name = accountName;
                acc.Description = 'New Account';
            }
            // Upsert the Account
            upsert acc;
            return acc;

        }

    /**
     * Question 10
	 * Upserts accounts and links contacts to them based on the contact's last name and account name.
	 * Create or use existing account with contact last name. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
	 * Contacts are then linked to these accounts based on a full last name match.
     * Example Contact Last Name = Doe Link to Account Name = Doe 
     * Example Contact Last Name = Jane Link to Account Name = Jane
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {

        //Check if there is any existing account
        //If account found with contact last name, update the current contact
        //If account not found, create an account and map it to current contact
        Set<String> contactLastNames = new Set<String>();
        for (Contact con : contactsToUpsert) {
          contactLastNames.add(con.LastName);
        }
        
        List<Account> existingAccounts = [SELECT Name FROM Account WHERE Name IN :contactLastNames];
        Map<String, Id> existingAccountNameToID = new Map<String, Id>();
        for(Account acc : existingAccounts){
            existingAccountNameToID.put(acc.Name, acc.Id);
        }
        
        List<Account> accountsToCreate = new List<Account>();
        for (Contact con : contactsToUpsert) {
          if (!existingAccountNameToID.containsKey(con.LastName)) {
            accountsToCreate.add(new Account(Name = con.LastName));
          }
          else {
            con.AccountId = existingAccountNameToID.get(con.LastName);
          }
        }
        
        if (accountsToCreate.size() > 0) {
          insert accountsToCreate;
        }
        
        for(Contact con : contactsToUpsert){
                for(Account acc : new Set<Account>([SELECT Id, Name FROM Account])){
                    if(con.LastName == acc.Name){
                        if(con.AccountId != acc.Id){
                            con.AccountId = acc.Id;
                        }
                    }
                }
            
        }
        upsert contactsToUpsert;

        /*
        Set<String> uniqueAccounts = new Set<String>();
        for(Contact cont : contactsToUpsert){
            uniqueAccounts.add(cont.LastName);
        }
        List<Account> accountsToInsert = new List<Account>();
        for(String accName : uniqueAccounts){
            List<Account> existingAcc = [SELECT Id, Name FROM Account WHERE Name != :accName LIMIT 1];
            if(!existingAcc.isEmpty()){
                Account a = new Account();
                a.Name = accName;
                accountsToInsert.add(a);
            }
        }
        if(!accountsToInsert.isEmpty()){
            insert accountsToInsert;
        }

        for(Contact cont : contactsToUpsert){
            List<Account> acc = [SELECT Id FROM Account WHERE Name = :cont.LastName LIMIT 1];
            if(!acc.isEmpty()){
                cont.AccountId = acc[0].Id;
            }

        }
        upsert contactsToUpsert;*/
    }


    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        List<Lead> leadsToBeInserted = new List<Lead>();
        for(String currentLead : leadNames){
            Lead l = new Lead();
            l.LastName = currentLead;
            l.Company = 'Test Comppany';
            l.Status = 'Open - Not Contacted';
            leadsToBeInserted.add(l);
        }
        // Insert the Leads
        insert leadsToBeInserted;

        // Delete the Leads
        delete leadsToBeInserted;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */

    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToBeInserted = new List<Case>();
        for(Integer i = 1; i <= numOfCases; i++){
            Case c = new Case();
            c.AccountId = accountId;
            c.status = 'New';
            casesToBeInserted.add(c);
        }
        // Insert the cases
        insert casesToBeInserted;
        // Delete the cases
        List<Case> casesToBeDeleted = [SELECT Id FROM Case WHERE AccountId = :accountId ];
        delete casesToBeDeleted;
    }
}