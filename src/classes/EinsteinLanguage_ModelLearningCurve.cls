public class EinsteinLanguage_ModelLearningCurve {

    @AuraEnabled
    public Integer epoch {get; set;}

    @AuraEnabled
    public List<EinsteinLanguage_EpochResult> epochResults {get; set;}

    @AuraEnabled
    public EinsteinLanguage_ModelMetrics modelMetrics {get; set;}

}