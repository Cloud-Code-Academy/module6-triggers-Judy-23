

trigger AccountTrigger on Account (before insert, before update, after insert) {
         // Before insert logic
        if (Trigger.isBefore && Trigger.isInsert) {
            for (Account acc : Trigger.new) {
            if (acc.Type == null) {
                acc.Type = 'Prospect';
        }

        // Copy Shipping Address to Billing Address during insert if Shipping Address fields are not null
        if (acc.ShippingStreet != null && acc.ShippingCity != null && 
            acc.ShippingState != null && acc.ShippingPostalCode != null && 
            acc.ShippingCountry != null) {
            acc.BillingStreet = acc.ShippingStreet;
            acc.BillingCity = acc.ShippingCity;
            acc.BillingState = acc.ShippingState;
            acc.BillingPostalCode = acc.ShippingPostalCode;
            acc.BillingCountry = acc.ShippingCountry;
            
        }

              // Set Rating to 'Hot' if Phone, Website, and Fax are all not null during insert
        if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
            acc.Rating = 'Hot';
        }

    }
}
        
            // After insert logic
        if (Trigger.isAfter && Trigger.isInsert) {
            List<Contact> contactsToInsert = new List<Contact>();
            for (Account acc : Trigger.new) {
            // Create a default contact for each new account
            Contact defaultContact = new Contact(
                LastName = 'DefaultContact',
                Email = 'default@email.com',
                AccountId = acc.Id
            );
            contactsToInsert.add(defaultContact);
    }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
    }
 }
 
}
   

    