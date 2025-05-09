package model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private String phone;
    private String role;
    private boolean isAdmin;
    private String profileImage;
    private String address;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public User() {}

    public User(int id, String firstName, String lastName, String email, String password, String phone, String role,
            boolean isAdmin, String profileImage, String address, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = role;
        this.isAdmin = isAdmin;
        this.profileImage = profileImage;
        this.address = address;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getRole() { return role; }
    public void setRole(String role) {
        this.role = role;
        this.isAdmin = role != null && "admin".equalsIgnoreCase(role.trim());
    }
    public boolean isAdmin() { return isAdmin; }
    public void setAdmin(boolean isAdmin) {
        this.isAdmin = isAdmin;
        if (isAdmin && (role == null || !role.equalsIgnoreCase("admin"))) {
            this.role = "admin";
        }
    }
    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Get the full name of the user (first name + last name)
     * @return Full name of the user
     */
    public String getFullName() {
        String first = (firstName != null) ? firstName : "";
        String last = (lastName != null) ? lastName : "";
        return first + " " + last;
    }


    @Override
    public String toString() {
        return "User{id=" + id + ", firstName='" + firstName + "', lastName='" + lastName + "', email='" + email +
               "', phone='" + phone + "', role='" + role + "', isAdmin=" + isAdmin + ", profileImage='" + profileImage +
               "', address='" + address + "', createdAt=" + createdAt + ", updatedAt=" + updatedAt + "}";
    }
}