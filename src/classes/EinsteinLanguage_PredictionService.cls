public class EinsteinLanguage_PredictionService {

    // TODO 共通のものはすべてスーパークラスに移して拡張する
    // EinsteinBase_PredictionService

    // Base URL for the PredictionService
    private static String BASE_URL = 'https://api.einstein.ai/v2';
    private static String LANGUAGE = '/language';

    private static String MODELS    = BASE_URL + LANGUAGE + '/models';
    private static String DATASETS  = BASE_URL + LANGUAGE + '/datasets';
    private static String TRAIN     = BASE_URL + LANGUAGE + '/train';
    private static String INTENT    = BASE_URL + LANGUAGE + '/intent';
    private static String SENTIMENT = BASE_URL + LANGUAGE + '/sentiment';

    private static String PREDICT   = BASE_URL + LANGUAGE + '/predict';
    private static String API_USAGE = BASE_URL + '/apiusage';
    private static String OAUTH2    = BASE_URL + '/oauth2/token';

    private static String UPLOAD   = '/upload';
    private static String LABELS   = '/labels';
    private static String EXAMPLES = '/examples';

    private boolean isExecuting = false;
    private String bearerToken = '';
    public Integer httpStatusCode = 0;

    /**
    * <p>Create a new object of type EinsteinLanguage_PredictionService.</p>
    * <p>The EinsteinLanguage_PredictionService is the foundation for communicating with the Salesforce Einstein Prediction Service.
    */
    public EinsteinLanguage_PredictionService() {
        System.debug(LoggingLevel.FINE, 'START EinsteinLanguage_PredictionService');

        this.bearerToken = getAccessToken();
    }

    /**
    * <p>Create a new object of type EinsteinLanguage_PredictionService.</p>
    * <p>The EinsteinLanguage_PredictionService is the foundation for communicating with the Salesforce Einstein Prediction Service.
    * @param bearerToken
    * A valid Bearer token
    */
    public EinsteinLanguage_PredictionService(String bearerToken) {
        System.debug(LoggingLevel.FINE, 'START EinsteinLanguage_PredictionService');

        this.bearerToken = bearerToken;
    }

    public static String getAccessToken() {
        System.debug(LoggingLevel.FINE, 'START getAccessToken');

        EinsteinAI_Settings__c settings = EinsteinAI_Settings__c.getOrgDefaults();
        ContentVersion base64Content = [
            SELECT Title, VersionData
            FROM ContentVersion
            WHERE Title = 'einstein_platform'
            LIMIT 1
        ];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        // Get a new token
        EinsteinAI_JWT jwt = new EinsteinAI_JWT('RS256');
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = settings.Einstein_EMail__c;
        jwt.aud = OAUTH2;
        jwt.exp = '3600';

        String accessToken = '';
        if (!Test.isRunningTest()) {
            accessToken = EinsteinAI_JWTBearerFlow.getAccessToken(OAUTH2, jwt);
        }

        return accessToken;
    }

    /**
    * Gets all EinsteinLanguage_Datasets of the authenticated user.
    * @return
    * An array of all EinsteinLanguage_Datasets
    */
    public EinsteinLanguage_Dataset[] getDatasets() {
        System.debug(LoggingLevel.FINE, 'START getDatasets');

        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getDatasets has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Dataset[] datasets = (EinsteinLanguage_Dataset[])client.getParser().readValueAs(EinsteinLanguage_Dataset[].class);
            System.debug('Datasets have been read.');
            return datasets;
        }
        return null;
    }

    public String getBearerToken() {
        System.debug(LoggingLevel.FINE, 'START getBearerToken');

        return bearerToken;
    }

    public void isExecuting(boolean isExecuting) {
        System.debug(LoggingLevel.FINE, 'START isExecuting');

        this.isExecuting = isExecuting;

        System.debug(LoggingLevel.FINE, 'END isExecuting');
    }

    private void handleError(Integer statusCode, String message) {
        System.debug(LoggingLevel.FINE, 'START handleError');

        httpStatusCode = statusCode;
        System.debug(LoggingLevel.Error, 'Response finished with Error: ' + message);

        System.debug(LoggingLevel.FINE, 'END handleError');
    }

    /**
    * Gets all trained EinsteinLanguage_Models that are trained for the given EinsteinLanguage_Dataset.
    * @param dataset
    * The EinsteinLanguage_Dataset to which the EinsteinLanguage_Models are assigned.
    * @return
    * @
    */
    public EinsteinLanguage_Model[] getModels(EinsteinLanguage_Dataset dataset) {
        System.debug(LoggingLevel.FINE, 'START getModels');

        return getModels(dataset.id);
    }

    /**
    * Gets all trained EinsteinLanguage_Models that are trained for the given EinsteinLanguage_Dataset.
    * @param datasetId
    * The EinsteinLanguage_Dataset id to which the EinsteinLanguage_Models are assigned.
    * @return
    * @
    */
    public EinsteinLanguage_Model[] getModels(Long datasetId) {
        System.debug(LoggingLevel.FINE, 'START getModels');

        // TODO datasetの時と同じロジックになってるので共通化できる
        System.debug('Starting getModels call');
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + '/models');
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getModels has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Model[] models = (EinsteinLanguage_Model[])client.getParser().readValueAs(EinsteinLanguage_Model[].class);
            System.debug('Models have been read.');
            return models;
        }
        return null;
    }

    // public EinsteinLanguage_PredictionResult intent(EinsteinLanguage_Model model, String document, String sampleId) {
    //     System.debug(LoggingLevel.FINE, 'START intent');

    //     return intent(model.modelId, document, sampleId);
    // }

    public EinsteinLanguage_PredictionResult intent(String modelId, String document, String sampleId) {
        System.debug(LoggingLevel.FINE, 'START intent');

        System.debug('Starting predict call with model ' + modelId);
        EinsteinLanguage_HttpBodyPartPrediction parts = new EinsteinLanguage_HttpBodyPartPrediction(modelId, null, document, EinsteinLanguage_HttpBodyPartPrediction.Types.BASE64);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, INTENT, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call predict has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_PredictionResult predictions = (EinsteinLanguage_PredictionResult)client.getParser().readValueAs(EinsteinLanguage_PredictionResult.class);
            System.debug('Image has been predicted.');
            return predictions;
        }
        return null;
    }

    public EinsteinLanguage_PredictionResult sentiment(String modelId, String document, String sampleId) {
        System.debug(LoggingLevel.FINE, 'START sentiment');

        System.debug('Starting predict call with model ' + modelId);
        EinsteinLanguage_HttpBodyPartPrediction parts = new EinsteinLanguage_HttpBodyPartPrediction(modelId, null, document, EinsteinLanguage_HttpBodyPartPrediction.Types.BASE64);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, SENTIMENT, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call predict has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_PredictionResult predictions = (EinsteinLanguage_PredictionResult)client.getParser().readValueAs(EinsteinLanguage_PredictionResult.class);
            System.debug('Image has been predicted.');
            return predictions;
        }
        return null;
    }


    /**
    * Creates a new EinsteinLanguage_Dataset. A EinsteinLanguage_Dataset is basically a group of different object types (named as 'Label').
    * @param name
    * The name of the EinsteinLanguage_Dataset
    * @param labels
    * An array of labels that will be used in the EinsteinLanguage_Dataset, i. e. 'Beaches', 'Mountains' etc.
    * @return
    * @
    */
    public EinsteinLanguage_Dataset createDataset(String name, String[] labels) {
        System.debug('Starting createDataset call with name ' + name);
        EinsteinLanguage_HttpBodyPartDataset parts = new EinsteinLanguage_HttpBodyPartDataset(name, labels);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call createDataset has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Dataset dataset = (EinsteinLanguage_Dataset)client.getParser().readValueAs(EinsteinLanguage_Dataset.class);
            System.debug('New Dataset with id ' + dataset.id + ' has been created.');
            return dataset;
        }
        return null;
    }

    /**
    * Creates a new dataset with images from a remote zip file (async call).
    * @param url
    * The remote URL of the to be trained image.
    * @return
    * @
    */
    public EinsteinLanguage_Dataset createDatasetFromUrlAsync(String url) {
        System.debug('Starting createDatasetFromUrlAsync call from URL ' + url);
        EinsteinLanguage_HttpBodyPartDatasetUrl parts = new EinsteinLanguage_HttpBodyPartDatasetUrl(url);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + UPLOAD, parts.build());
        client.isPost(true);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call createDatasetFromUrlAsync has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Dataset dataset = (EinsteinLanguage_Dataset)client.getParser().readValueAs(EinsteinLanguage_Dataset.class);
            System.debug('New dataset with id ' + dataset.id + ' has been created.');
            return dataset;
        }
        return null;
    }

    /**
    * Creates a new dataset with images from a remote zip file (sync).
    * @param url
    * The remote URL of the to be trained image.
    * @return
    * @
    */
    public EinsteinLanguage_Dataset createDatasetFromUrlSync(String url) {
        System.debug('Starting createDatasetFromUrlSync call from URL ' + url);
        EinsteinLanguage_HttpBodyPartDatasetUrl parts = new EinsteinLanguage_HttpBodyPartDatasetUrl(url);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + UPLOAD + '/sync', parts.build());
        client.isPost(true);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call createDatasetFromUrlSync has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Dataset dataset = (EinsteinLanguage_Dataset)client.getParser().readValueAs(EinsteinLanguage_Dataset.class);
            System.debug('New dataset with id ' + dataset.id + ' has been created.');
            return dataset;
        }
        return null;
    }

    /**
    * Gets an existing EinsteinLanguage_Dataset.
    * @param id
    * The id of the EinsteinLanguage_Dataset that needs to be fetched.
    * @return
    * @
    */
    public EinsteinLanguage_Dataset getDataset(Long id) {
        if (id==0) {
            throw new EinsteinLanguage_NoValuesException('datasetId');
        }
        System.debug('Starting getDataset call with parameter ' + id);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + id);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getDataset has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Dataset dataset = (EinsteinLanguage_Dataset)client.getParser().readValueAs(EinsteinLanguage_Dataset.class);
            System.debug('Dataset has been read.');
            return dataset;
        }
        return null;
    }

    /**
    * Deletes an existing dataset.
    * @param dataset
    * The EinsteinLanguage_Dataset that should be deleted.
    * @return
    * True if the deletion was successful.
    */
    public boolean deleteDataset(EinsteinLanguage_Dataset dataset) {
        return deleteDataset(dataset.id);
    }

    /**
    * Deletes an existing dataset.
    * @param id
    * The id of the EinsteinLanguage_Dataset that should be deleted.
    * @return
    * True if the deletion was successful.
    */
    public boolean deleteDataset(Long id) {
        System.debug('Starting deleteDataset call');
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + id);
        client.isDelete(true);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call deleteDataset has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            System.debug('Dataset ' + id + ' has been deleted.');
            return true;
        }
        return false;
    }

    /**
    * Creates a new EinsteinLanguage_Label within an existing EinsteinLanguage_Dataset.
    * @param datasetId
    * The id of the EinsteinLanguage_Dataset.
    * @param name
    * The new EinsteinLanguage_Label name.
    * @return
    * @
    */
    public EinsteinLanguage_Label createLabel(Long datasetId, String name) {
        System.debug('Starting createLabel call with name ' + name);
        EinsteinLanguage_HttpBodyPartLabel parts = new EinsteinLanguage_HttpBodyPartLabel(name);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + LABELS, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call createLabel has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Label label = (EinsteinLanguage_Label)client.getParser().readValueAs(EinsteinLanguage_Label.class);
            System.debug('Label ' + name + ' has been created.');
            return label;
        }
        return null;
    }

    /**
    * Gets an existing EinsteinLanguage_Label from a EinsteinLanguage_Dataset.
    * @param datasetId
    * The id of the associated EinsteinLanguage_Dataset.
    * @param id
    * The id of the EinsteinLanguage_Dataset that needs to be fetched.
    * @return
    * @
    */
    public EinsteinLanguage_Label getLabel(Long datasetId, Integer id) {
        System.debug('Starting getLabel call with id ' + id);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + LABELS + '/' + id);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getLabel has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Label label = (EinsteinLanguage_Label)client.getParser().readValueAs(EinsteinLanguage_Label.class);
            System.debug('Label ' + id + ' has been read.');
            return label;
        }
        return null;
    }

    /**
    * Adds new image examples for the predictive vision training.
    * @param datasetId
    * The id of the EinsteinLanguage_Dataset to which the image should be added.
    * @param name
    * The name of the example.
    * @param fileBlob
    * The blog of the to be trained image.
    * @return
    * @
    */
    public EinsteinLanguage_Example createExample(Long datasetId, String name, Long labelId, Blob fileBlob) {
        System.debug('Starting createExample call from blob');
        EinsteinLanguage_HttpBodyPartExample parts = new EinsteinLanguage_HttpBodyPartExample(name, labelId, EncodingUtil.base64Encode(fileBlob));
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + EXAMPLES, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.isPost(true);
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call createExample from blob has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Example example = (EinsteinLanguage_Example)client.getParser().readValueAs(EinsteinLanguage_Example.class);
            System.debug('New example with id ' + example.id + ' has been created.');
            return example;
        }
        return null;
    }

    /**
    * Adds new image examples for the predictive vision training via a remote zip file.
    * @param datasetId
    * The id of the EinsteinLanguage_Dataset to which the image should be added.
    * @param url
    * The remote URL of the to be trained image.
    * @return
    * @
    */
    public EinsteinLanguage_Dataset createExamplesFromUrl(Long datasetId, String url) {
        System.debug('Starting createExamplesFromUrl call from URL ' + url);
        EinsteinLanguage_HttpBodyPartDatasetUrl parts = new EinsteinLanguage_HttpBodyPartDatasetUrl(url);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + UPLOAD, parts.build());
        client.isPut(true);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call createExampleFromUrl has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Dataset dataset = (EinsteinLanguage_Dataset)client.getParser().readValueAs(EinsteinLanguage_Dataset.class);
            System.debug('New examples for dataset with id ' + dataset.id + ' have been created.');
            return dataset;
        }
        return null;
    }

    /**
    * Gets data about an existing example.
    * @param datasetId
    * The EinsteinLanguage_Dataset id to which the example beLongs.
    * @param id
    * The id of the EinsteinLanguage_Example.
    * @return
    * @
    */
    public EinsteinLanguage_Example getExample(Long datasetId, Long id) {
        System.debug('Starting getExample call with id ' + id);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + EXAMPLES + '/' + id);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getExample has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Example example = (EinsteinLanguage_Example)client.getParser().readValueAs(EinsteinLanguage_Example.class);
            System.debug('Example ' + id + ' has been read.');
            return example;
        }
        return null;
    }

    /**
    * Gets an array of all EinsteinLanguage_Examples that are associated with the given Dataset.
    * @param dataset
    * The EinsteinLanguage_Dataset to which the EinsteinLanguage_Examples are associated.
    * @return
    * @
    */
    public EinsteinLanguage_Example[] getExamples(EinsteinLanguage_Dataset dataset) {
        return getExamples(dataset.id);
    }

    /**
    * Gets an array of all EinsteinLanguage_Examples that are associated with the given EinsteinLanguage_Dataset.
    * @param datasetId
    * The id of the EinsteinLanguage_Dataset to which the EinsteinLanguage_Examples are associated.
    * @return
    * @
    */
    public EinsteinLanguage_Example[] getExamples(Long datasetId) {
        System.debug('Starting getExamples call');
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + EXAMPLES);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getExamples has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Example[] examples = (EinsteinLanguage_Example[])client.getParser().readValueAs(EinsteinLanguage_Example[].class);
            System.debug('Examples have been read.');
            return examples;
        }
        return null;
    }

    /**
    * Deletes the given EinsteinLanguage_Example.
    * @param example
    * The EinsteinLanguage_Example that needs to be deleted.
    * @return
    * True if the deletion was successful.
    */
    public boolean deleteExample(EinsteinLanguage_Example example) {
        return deleteExample(example.label.datasetId, example.id);
    }

    /**
    * Deletes the given EinsteinLanguage_Example.
    * @param datasetId
    * The Dataset id to which the Example beLongs.
    * @param id
    * The id of the EinsteinLanguage_Example that needs to be deleted.
    * @return
    * True if the deletion was successful.
    */
    public boolean deleteExample(Long datasetId, Long id) {
        System.debug('Starting deleteExample call');
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, DATASETS + '/' + datasetId + EXAMPLES + '/' + id);
        client.isDelete(true);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call deleteExample has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            System.debug('Example ' + id + ' has been deleted.');
            return true;
        }
        return false;
    }

    /**
    * Starts the training of a EinsteinLanguage_Dataset.
    * @param dataset
    * The EinsteinLanguage_Dataset that should be trained.
    * @param name
    * The name of the EinsteinLanguage_Dataset.
    * @param epochs
    * Optional. The number of training iterations, valid values are between 1-100. Set to 0 if you want to use the default.
    * @param learningRate
    * Optional. The learning rate, valid values are betweed 0.0001 and 0.01. Set to 0 if you want to use the default.
    * @return
    * @
    */
    public EinsteinLanguage_Model trainDataset(EinsteinLanguage_Dataset dataset, String name, Integer epochs, Decimal learningRate, String trainParams) {
        return trainDataset(dataset.id, name, epochs, learningRate, trainParams);
    }

    /**
    * Starts the training of a EinsteinLanguage_Dataset.
    * @param datasetId
    * The EinsteinLanguage_Dataset id that should be trained.
    * @param name
    * The name of the EinsteinLanguage_Dataset.
    * @param epochs
    * Optional. The number of training iterations, valid values are between 1-100. Set to 0 if you want to use the default.
    * @param learningRate
    * Optional. The learning rate, valid values are betweed 0.0001 and 0.01. Set to 0 if you want to use the default.
    */
    public EinsteinLanguage_Model trainDataset(Long datasetId, String name, Integer epochs, Decimal learningRate, String trainParams) {
        EinsteinLanguage_Dataset dataset = getDataset(datasetId);
        if (dataset != null) {
            if (dataset.totalExamples>0) {
                System.debug('Starting trainDataset call with name ' + name);
                EinsteinLanguage_HttpBodyPartTraining parts = new EinsteinLanguage_HttpBodyPartTraining(datasetId, name, epochs, learningRate, trainParams);
                EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, TRAIN, parts.build());
                System.debug('Target URL is ' + client.getUrl());
                client.execute();
                while(isExecuting()) {
                    System.debug('Status is: ' + isExecuting());
                }
                System.debug('Call trainDataset has been executed.');
                if (client.isError()) {
                    handleError(client.getStatusCode(), client.getResponseError());
                } else {
                    EinsteinLanguage_Model model = (EinsteinLanguage_Model)client.getParser().readValueAs(EinsteinLanguage_Model.class);
                    System.debug('New Model with id ' + model.modelId + ' has been created.');
                    return model;
                }
            } else {
                System.debug('The dataset with id ' + datasetId + ' has no configured examples.');
            }
        }
        return null;
    }

    /**
    * Fetches the model for the given id.
    * @param modelId
    * The id of the model that needs to be fetched.
    * @return
    * @
    */
    public EinsteinLanguage_Model getModel(String modelId) {
        System.debug('Starting getModel call with parameter ' + modelId);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, TRAIN + '/' + modelId);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getModel has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_Model model = (EinsteinLanguage_Model)client.getParser().readValueAs(EinsteinLanguage_Model.class);
            System.debug('Model status has been read.');
            return model;
        }
        return null;
    }

    /**
    * Gets the learning curve of a model.
    * @param modelMetricsId
    * The model id for which the learning curve should be fetched.
    * @return
    * @
    */
    public EinsteinLanguage_ModelLearningCurve[] getModelLearningCurve(String modelMetricsId) {
        System.debug('Starting getModelLearningCurve call with parameter ' + modelMetricsId);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, MODELS + '/' + modelMetricsId + '/lc');
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getModelLearningCurve has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_ModelLearningCurve[] modelLearningCurve = (EinsteinLanguage_ModelLearningCurve[])client.getParser().readValueAs(EinsteinLanguage_ModelLearningCurve[].class);
            System.debug('ModelLearningCurve has been read.');
            return modelLearningCurve;
        }
        return null;
    }

    /**
    * Gets the metrics of a model.
    * @param modelMetricsId
    * The model id for which the metrics should be fetched.
    * @return
    * @
    */
    public EinsteinLanguage_ModelMetrics getModelMetrics(String modelMetricsId) {
        System.debug('Starting getModelMetrics call with parameter ' + modelMetricsId);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, MODELS + '/' + modelMetricsId);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getModelMetrics has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_ModelMetrics modelMetrics = (EinsteinLanguage_ModelMetrics)client.getParser().readValueAs(EinsteinLanguage_ModelMetrics.class);
            System.debug('ModelMetrics have been read.');
            return modelMetrics;
        }
        return null;
    }



    /**
    * Predicts the association of the given image in Base64 format to a trained model.
    * @param model
    * The EinsteinLanguage_Model that should be used for the prediction.
    * @param base64
    * The image that should be predicted.
    * @param sampleId
    * Optional. A string that gets returned as an association with the predicted image.
    * @return
    * @
    */
    public EinsteinLanguage_PredictionResult predictBase64(EinsteinLanguage_Model model, String base64, String sampleId) {
        return predictBase64(model.modelId, base64, sampleId);
    }

    /**
    * Predicts the association of the given image in Base64 format to a trained model.
    * @param modelId
    * The EinsteinLanguage_Model id that should be used for the prediction.
    * @param base64
    * The image that should be predicted.
    * @param sampleId
    * Optional. A string that gets returned as an association with the predicted image.
    * @return
    * @
    */
    public EinsteinLanguage_PredictionResult predictBase64(String modelId, String base64, String sampleId) {
        System.debug('Starting predict call with model ' + modelId + ' for base64');
        EinsteinLanguage_HttpBodyPartPrediction parts = new EinsteinLanguage_HttpBodyPartPrediction(modelId, base64, sampleId, EinsteinLanguage_HttpBodyPartPrediction.Types.BASE64);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, PREDICT, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call predict has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_PredictionResult predictions = (EinsteinLanguage_PredictionResult)client.getParser().readValueAs(EinsteinLanguage_PredictionResult.class);
            System.debug('Image has been predicted.');
            return predictions;
        }
        return null;
    }

    /**
    * Predicts the association of the given image in a file blob to a trained model.
    * @param model
    * The EinsteinLanguage_Model that should be used for the prediction.
    * @param fileBlob
    * The image blob for the prediction.
    * @param sampleId
    * Optional. A string that gets returned as an association with the predicted image.
    * @return
    * @
    */
    public EinsteinLanguage_PredictionResult predictBlob(EinsteinLanguage_Model model, Blob fileBlob, String sampleId) {
        return predictBlob(model.modelId, fileBlob, sampleId);
    }

    /**
    * Predicts the association of the given image on the local file system to a trained model.
    * @param modelId
    * The Model id that should be used for the prediction.
    * @param fileBlob
    * The image blob for the prediction.
    * @param sampleId
    * Optional. A string that gets returned as an association with the predicted image.
    * @return
    * @
    */
    public EinsteinLanguage_PredictionResult predictBlob(String modelId, Blob fileBlob, String sampleId) {
        System.debug('Starting predict call with model ' + modelId + ' for blob');
        EinsteinLanguage_HttpBodyPartPrediction parts = new EinsteinLanguage_HttpBodyPartPrediction(modelId, EncodingUtil.base64Encode(fileBlob), sampleId, EinsteinLanguage_HttpBodyPartPrediction.Types.BASE64);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, PREDICT, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call predict has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_PredictionResult predictions = (EinsteinLanguage_PredictionResult)client.getParser().readValueAs(EinsteinLanguage_PredictionResult.class);
            System.debug('Image has been predicted.');
            return predictions;
        }
        return null;
    }

    /**
    * Predicts the association of the given image on a remote url to a trained model.
    * @param model
    * The EinsteinLanguage_Model that should be used for the prediction.
    * @param url
    * The absolute url of the image.
    * @param sampleId
    * Optional. A string that gets returned as an association with the predicted image.
    * @return
    * @
    */
    public EinsteinLanguage_PredictionResult predictUrl(EinsteinLanguage_Model model, String url, String sampleId) {
        return predictUrl(model.modelId, url, sampleId);
    }

    /**
    * Predicts the association of the given image on a remote url to a trained model.
    * @param modelId
    * The Model id that should be used for the prediction.
    * @param url
    * The absolute url of the image.
    * @param sampleId
    * Optional. A string that gets returned as an association with the predicted image.
    * @return
    * @
    */
    public EinsteinLanguage_PredictionResult predictUrl(String modelId, String url, String sampleId) {
        System.debug('Starting predict call with model ' + modelId + ' for url');
        EinsteinLanguage_HttpBodyPartPrediction parts = new EinsteinLanguage_HttpBodyPartPrediction(modelId, url, sampleId, EinsteinLanguage_HttpBodyPartPrediction.Types.URL);
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, PREDICT, parts.build());
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while(isExecuting()) {
            System.debug('Status is: ' + isExecuting());
        }
        System.debug('Call predict has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_PredictionResult predictions = (EinsteinLanguage_PredictionResult)client.getParser().readValueAs(EinsteinLanguage_PredictionResult.class);
            System.debug('Image has been predicted.');
            return predictions;
        }
        return null;
    }

    /**
    * Fetches data about the API usage of the authenticated PredictionService.
    * @return
    * An array of all EinsteinLanguage_ApiUsage elements.
    */
    public EinsteinLanguage_ApiUsage[] getApiUsage() {
        System.debug('Starting getApiUsage call');
        EinsteinLanguage_HttpClient client = new EinsteinLanguage_HttpClient(this, API_USAGE);
        System.debug('Target URL is ' + client.getUrl());
        client.execute();
        while (isExecuting()) {
            System.debug('Status is: ' + isExecuting() );
        }
        System.debug('Call getApiUsage has been executed.');
        if (client.isError()) {
            handleError(client.getStatusCode(), client.getResponseError());
        } else {
            EinsteinLanguage_ApiUsage[] apiUsage = (EinsteinLanguage_ApiUsage[])client.getParser().readValueAs(EinsteinLanguage_ApiUsage[].class);
            System.debug('API usage has been fetched.');
            return apiUsage;
        }
        return null;
    }

    /**
    *
    * @return
    */
    public boolean isExecuting() {
        return isExecuting;
    }

    /**
    *
    * @param isExecuting
    */

    /**
    *
    * @param message
    */

}