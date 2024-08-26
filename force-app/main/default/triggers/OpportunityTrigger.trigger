trigger OpportunityTrigger on Opportunity (before update, before delete) {
    // Maps for storing relevant data
    Map<Id, Opportunity> oldOpportunities = new Map<Id, Opportunity>();
    Map<Id, Id> accountToCEOContactMap = new Map<Id, Id>();

    if (Trigger.isUpdate) {
        // Collect Account IDs from updated Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            accountIds.add(opp.AccountId);
        }

        // Query for CEO Contacts
        List<Contact> ceoContacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE Title = 'CEO'
            AND AccountId IN :accountIds
        ];
        
        // Map Account IDs to CEO Contact IDs
        for (Contact con : ceoContacts) {
            accountToCEOContactMap.put(con.AccountId, con.Id);
        }

        // Perform amount validation and set primary contact
        for (Opportunity opp : Trigger.new) {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

            // Amount Validation
            if (opp.Amount != oldOpp.Amount && opp.Amount <= 5000) {
                opp.addError('Opportunity amount must be greater than 5000');
            }

            // Set Primary Contact
            if (accountToCEOContactMap.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = accountToCEOContactMap.get(opp.AccountId);
            } else {
                opp.Primary_Contact__c = null;
            }
        }
    }

    if (Trigger.isDelete) {
        // Collect Account IDs from deleted Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.old) {
            accountIds.add(opp.AccountId);
        }

        // Query for Accounts with 'Banking' Industry
        Map<Id, Account> accountsWithBankingIndustry = new Map<Id, Account>();
        for (Account acc : [
            SELECT Id
            FROM Account
            WHERE Id IN :accountIds
            AND Industry = 'Banking'
        ]) {
            accountsWithBankingIndustry.put(acc.Id, acc);
        }

        // Prevent deletion of closed won opportunities if account industry is 'Banking'
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && accountsWithBankingIndustry.containsKey(opp.AccountId)) {
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
}


