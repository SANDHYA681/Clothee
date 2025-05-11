package model;

/**
 * Slide model class
 */
public class Slide {
    private String imageUrl;
    private String title;
    private String subtitle;
    private String primaryButtonUrl;
    private String primaryButtonText;
    private String secondaryButtonUrl;
    private String secondaryButtonText;
    
    /**
     * Default constructor
     */
    public Slide() {
    }
    
    /**
     * Constructor with parameters
     * 
     * @param imageUrl Image URL
     * @param title Title
     * @param subtitle Subtitle
     * @param primaryButtonUrl Primary button URL
     * @param primaryButtonText Primary button text
     * @param secondaryButtonUrl Secondary button URL
     * @param secondaryButtonText Secondary button text
     */
    public Slide(String imageUrl, String title, String subtitle, String primaryButtonUrl, String primaryButtonText,
            String secondaryButtonUrl, String secondaryButtonText) {
        this.imageUrl = imageUrl;
        this.title = title;
        this.subtitle = subtitle;
        this.primaryButtonUrl = primaryButtonUrl;
        this.primaryButtonText = primaryButtonText;
        this.secondaryButtonUrl = secondaryButtonUrl;
        this.secondaryButtonText = secondaryButtonText;
    }

    /**
     * @return the imageUrl
     */
    public String getImageUrl() {
        return imageUrl;
    }

    /**
     * @param imageUrl the imageUrl to set
     */
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    /**
     * @return the title
     */
    public String getTitle() {
        return title;
    }

    /**
     * @param title the title to set
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * @return the subtitle
     */
    public String getSubtitle() {
        return subtitle;
    }

    /**
     * @param subtitle the subtitle to set
     */
    public void setSubtitle(String subtitle) {
        this.subtitle = subtitle;
    }

    /**
     * @return the primaryButtonUrl
     */
    public String getPrimaryButtonUrl() {
        return primaryButtonUrl;
    }

    /**
     * @param primaryButtonUrl the primaryButtonUrl to set
     */
    public void setPrimaryButtonUrl(String primaryButtonUrl) {
        this.primaryButtonUrl = primaryButtonUrl;
    }

    /**
     * @return the primaryButtonText
     */
    public String getPrimaryButtonText() {
        return primaryButtonText;
    }

    /**
     * @param primaryButtonText the primaryButtonText to set
     */
    public void setPrimaryButtonText(String primaryButtonText) {
        this.primaryButtonText = primaryButtonText;
    }

    /**
     * @return the secondaryButtonUrl
     */
    public String getSecondaryButtonUrl() {
        return secondaryButtonUrl;
    }

    /**
     * @param secondaryButtonUrl the secondaryButtonUrl to set
     */
    public void setSecondaryButtonUrl(String secondaryButtonUrl) {
        this.secondaryButtonUrl = secondaryButtonUrl;
    }

    /**
     * @return the secondaryButtonText
     */
    public String getSecondaryButtonText() {
        return secondaryButtonText;
    }

    /**
     * @param secondaryButtonText the secondaryButtonText to set
     */
    public void setSecondaryButtonText(String secondaryButtonText) {
        this.secondaryButtonText = secondaryButtonText;
    }
}
