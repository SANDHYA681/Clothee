package util;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import model.Category;

public class CheckCategories {
    public static void main(String[] args) {
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM categories");
            
            List<Category> categories = new ArrayList<>();
            
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setName(rs.getString("name"));
                category.setDescription(rs.getString("description"));
                category.setImageUrl(rs.getString("image_url"));
                category.setCreatedAt(rs.getTimestamp("created_at"));
                categories.add(category);
            }
            
            System.out.println("Found " + categories.size() + " categories:");
            for (Category category : categories) {
                System.out.println(category);
            }
            
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
