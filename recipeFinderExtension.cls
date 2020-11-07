public class recipeFinderExtension {
    
    //get, set methods for filteredRecipes list
    public List<Recipe__c> filteredRecipes {get;set;}
    public List<SelectOption> ingredientOptions {get;set;}
    public List<String> requiredIngredients {get; set;}
    public List<SelectOption> dietaryOptions {get;set;}
    public List<String> requiredDietaryRestrictions {get; set;}
    
    //controller extension constructor
    public recipeFinderExtension(ApexPages.StandardSetController controller){
        {
            this.filteredRecipes = [SELECT Name FROM Recipe__c];           
            
            //Set ingredient picklist
            transient Schema.DescribeFieldResult dfrIng = Recipe__c.Ingredients__c.getDescribe();
            transient List<Schema.PicklistEntry> ingredientPLEntries = dfrIng.getPicklistValues();
            this.ingredientOptions = New List<SelectOption>();
            for(Schema.PicklistEntry pleIng : ingredientPLEntries){
                this.ingredientOptions.add(new SelectOption(pleIng.getValue(),pleIng.getLabel()));
            }
            
            //Set dietary resrictions picklist
            transient Schema.DescribeFieldResult dfrDR = Recipe__c.Dietary_Restrictions__c.getDescribe();
            transient List<Schema.PicklistEntry> dietaryPLEntries = dfrDR.getPicklistValues();
            this.dietaryOptions = New List<SelectOption>();
            for(Schema.PicklistEntry pleDR : dietaryPLEntries){
                this.dietaryOptions.add(new SelectOption(pleDR.getValue(),pleDR.getLabel()));
            }
        }         
    }
    
    public void clearRequiredIngredients(){
        requiredIngredients.clear();
    }
    
    public void clearDietaryRestrictions(){
        requiredDietaryRestrictions.clear();
    }
    
    public void search(){
        String query = 'SELECT Name, Ingredients__c FROM Recipe__c';
        Boolean hasIng = requiredIngredients.size() > 0;
        Boolean hasDR = requiredDietaryRestrictions.size() > 0;
        
        if(hasIng || hasDR) {
            query += ' WHERE ';
            query += ingredientsFilter();   
            if(hasIng && hasDR){
                query += ' AND ';
            }
            query += dietaryRestrictionsFilter();            
        }

         system.debug(query);
            this.filteredRecipes = Database.query(query);
    } //end of search method

    private String ingredientsFilter() {
        if (requiredIngredients.isEmpty()) {
            return '';              
        }
        String s = String.join(requiredIngredients, ';');
        return 'Recipe_c.Ingredients__c INCLUDES (\'' + s + '\')';
    }

    private String dietaryRestrictionsFilter() {
        if (requiredDietaryRestrictions.isEmpty()) {
            return '';              
        }
        String s = String.join(requiredDietaryRestrictions, ';');
        return 'Recipe_c.Dietary_Restrictions__c INCLUDES (\'' + s  + '\')';
    }

}