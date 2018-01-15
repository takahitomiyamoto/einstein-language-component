public with sharing class EinsteinLanguage_HttpBodyPartDatasetUrl extends EinsteinLanguage_HttpBodyPart {

    private String url;

    public EinsteinLanguage_HttpBodyPartDatasetUrl(String url)  {
        if (url==null || url.equals('')) {
            throw new EinsteinLanguage_StringIsEmptyException('url');
        }
        this.url = url;
    }

    public Blob build() {
        String body = '';
        body += WriteBoundary();
        body += WriteBodyParameter('path', url);
        body += WriteBoundary(EndingType.CrLf);
        Blob bodyBlob = EncodingUtil.base64Decode(body);
        return bodyBlob;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url)  {
        if (url == null || url.equals('')) {
            throw new EinsteinLanguage_StringIsEmptyException('url');
        }
        this.url = url;
    }

}