public class EinsteinLanguage_HttpBodyPartPrediction extends EinsteinLanguage_HttpBodyPart {

    public enum Types {
        BASE64,
        FILEBLOB,
        URL
    }

    private String modelId;
    private String data;
    private String document;
    private Types type;

    public EinsteinLanguage_HttpBodyPartPrediction(String modelId, String data, String document, Types type) {
        System.debug(LoggingLevel.FINE, 'START builEinsteinLanguage_HttpBodyPartPredictiond');

        this.modelId = modelId;
        this.data = data;
        this.document = document;
        this.type = type;
    }

    public Blob build() {
        System.debug(LoggingLevel.FINE, 'START build');

        String body = '';
        body += WriteBoundary();
        body += WriteBodyParameter('modelId', modelId);
        if (document != null && !document.equals('')) {
            body += WriteBoundary();
            body += WriteBodyParameter('document', document);
        }
        body += WriteBoundary(EndingType.CrLf);
        System.debug(LoggingLevel.FINE, 'body: ' + body);
        Blob bodyBlob = EncodingUtil.base64Decode(body);
        return bodyBlob;
    }

    public String getModelId() {
        return modelId;
    }

    public void setModelId(String modelId) {
        this.modelId = modelId;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public String getDocument() {
        return document;
    }

    public void setDocument(String document) {
        this.document = document;
    }

    public Types getType() {
        return type;
    }

    public void setType(Types type) {
        this.type = type;
    }

}