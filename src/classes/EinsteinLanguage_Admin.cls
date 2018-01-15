public class EinsteinLanguage_Admin {

    @AuraEnabled
    public static String getSessionId() {
        System.debug(Logginglevel.FINE, 'START getSessionId');

        return UserInfo.getSessionId();
    }

    @AuraEnabled
    public static String callEinsteinIntent(String document) {
        System.debug(LoggingLevel.FINE, 'START callEinsteinIntent');

        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        EinsteinLanguage_Dataset[] datasets = predictionService.getDatasets();

        List<EinsteinLanguage_PredictionResult> results = new List<EinsteinLanguage_PredictionResult>();
        for (EinsteinLanguage_Dataset dataset : datasets) {
            EinsteinLanguage_Model[] models = predictionService.getModels(dataset);
            EinsteinLanguage_Model model = models.get(0);
            EinsteinLanguage_PredictionResult result = predictionService.intent(model.modelId, document, '');
            results.add(result);
        }

        return System.JSON.serialize(results);
    }

    @AuraEnabled
    public static String callEinsteinSentiment(String document) {
        System.debug(LoggingLevel.FINE, 'START callEinsteinSentiment');

        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        EinsteinLanguage_Dataset[] datasets = predictionService.getDatasets();

        List<EinsteinLanguage_PredictionResult> results = new List<EinsteinLanguage_PredictionResult>();
        for (EinsteinLanguage_Dataset dataset : datasets) {
            // EinsteinLanguage_Model[] models = predictionService.getModels(dataset);
            // EinsteinLanguage_Model model = models.get(0);
            EinsteinLanguage_PredictionResult result = predictionService.sentiment('CommunitySentiment', document, '');
            results.add(result);
        }

        return System.JSON.serialize(results);
    }

    @AuraEnabled
    public static void createDatasetFromUrl(String zipUrl) {
        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        predictionService.createDatasetFromUrlAsync(zipUrl);
    }

    @AuraEnabled
    public static List<EinsteinLanguage_Dataset> getDatasets() {
        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        EinsteinLanguage_Dataset[] datasets = predictionService.getDatasets();
        return datasets;
    }

    @AuraEnabled
    public static String trainDataset(Decimal datasetId) {
        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        EinsteinLanguage_Model model = predictionService.trainDataset(Long.valueOf(String.valueOf(datasetId)), 'Training', 0, 0, '');
        return model.modelId;
    }

    @AuraEnabled
    public static void deleteDataset(Long datasetId) {
        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        predictionService.deleteDataset(datasetId);
    }

    @AuraEnabled
    public static List<EinsteinLanguage_Model> getModels(Long datasetId) {
        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        EinsteinLanguage_Model[] models = predictionService.getModels(datasetId);
        return models;
    }


    @AuraEnabled
    public static List<EinsteinLanguage_Label> getCatLabels() {
        EinsteinLanguage_PredictionService predictionService = new EinsteinLanguage_PredictionService();
        EinsteinLanguage_Dataset[] datasets = predictionService.getDatasets();
        for (EinsteinLanguage_Dataset dataset : datasets) {
            if (dataset.Name.equals('Cats')) {
                return dataset.labelSummary.labels;
            }
        }
        return null;
    }

    @AuraEnabled
    public static String getImageUrlFromAttachment(Id catId) {
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId=:catId];
        if (atts.size()>0) {
            return atts.get(0).Id;
        }
        return '';
    }

}