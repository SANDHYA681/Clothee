package controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.User;

/**
 * Servlet implementation class ImageDownloadServlet
 * Downloads product images from URLs and saves them to the appropriate directories
 */
// Servlet mapping defined in web.xml
public class ImageDownloadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Image URLs for different categories
    private static final Map<String, List<String>> IMAGE_URLS = new HashMap<>();

    static {
        // Men's category images
        List<String> menImages = new ArrayList<>();
        menImages.add("https://images.unsplash.com/photo-1617137968427-85924c800a22?q=80&w=1974&auto=format&fit=crop");
        menImages.add("https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=1964&auto=format&fit=crop");
        menImages.add("https://images.unsplash.com/photo-1600269452121-4f2416e55c28?q=80&w=1965&auto=format&fit=crop");
        menImages.add("https://images.unsplash.com/photo-1611312449408-fcece27cdbb7?q=80&w=1969&auto=format&fit=crop");
        menImages.add("https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?q=80&w=1974&auto=format&fit=crop");
        IMAGE_URLS.put("men", menImages);

        // Women's category images
        List<String> womenImages = new ArrayList<>();
        womenImages.add("https://images.unsplash.com/photo-1551163943-3f7fffb9d770?q=80&w=1964&auto=format&fit=crop");
        womenImages.add("https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?q=80&w=1935&auto=format&fit=crop");
        womenImages.add("https://images.unsplash.com/photo-1554568218-0f1715e72254?q=80&w=1974&auto=format&fit=crop");
        womenImages.add("https://images.unsplash.com/photo-1485968579580-b6d095142e6e?q=80&w=1965&auto=format&fit=crop");
        womenImages.add("https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=1962&auto=format&fit=crop");
        IMAGE_URLS.put("women", womenImages);

        // Kids' category images
        List<String> kidsImages = new ArrayList<>();
        kidsImages.add("https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=1972&auto=format&fit=crop");
        kidsImages.add("https://images.unsplash.com/photo-1519238359922-989348752efb?q=80&w=1974&auto=format&fit=crop");
        kidsImages.add("https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?q=80&w=2069&auto=format&fit=crop");
        kidsImages.add("https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?q=80&w=1974&auto=format&fit=crop");
        kidsImages.add("https://images.unsplash.com/photo-1503919545889-aef636e10ad4?q=80&w=1974&auto=format&fit=crop");
        IMAGE_URLS.put("kids", kidsImages);

        // Accessories category images
        List<String> accessoriesImages = new ArrayList<>();
        accessoriesImages.add("https://images.unsplash.com/photo-1549036214-e08b8cd5ee44?q=80&w=1970&auto=format&fit=crop");
        accessoriesImages.add("https://images.unsplash.com/photo-1556306535-0f09a537f0a3?q=80&w=1970&auto=format&fit=crop");
        accessoriesImages.add("https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?q=80&w=1994&auto=format&fit=crop");
        accessoriesImages.add("https://images.unsplash.com/photo-1591076482161-42ce6da69f67?q=80&w=1974&auto=format&fit=crop");
        accessoriesImages.add("https://images.unsplash.com/photo-1611652022419-a9419f74343d?q=80&w=1974&auto=format&fit=crop");
        IMAGE_URLS.put("accessories", accessoriesImages);
    }

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ImageDownloadServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Check if user is logged in and is admin
        if (user == null || !user.isAdmin()) {
            response.sendRedirect("LoginServlet");
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            // Show download page
            request.getRequestDispatcher("/admin/download-images.jsp").forward(request, response);
            return;
        }

        if ("download".equals(action)) {
            // Download images
            String category = request.getParameter("category");

            if (category == null || category.isEmpty()) {
                // Download all categories
                for (String cat : IMAGE_URLS.keySet()) {
                    downloadImages(cat);
                }
                session.setAttribute("successMessage", "All images downloaded successfully");
            } else {
                // Download specific category
                if (IMAGE_URLS.containsKey(category)) {
                    downloadImages(category);
                    session.setAttribute("successMessage", category + " images downloaded successfully");
                } else {
                    session.setAttribute("errorMessage", "Invalid category: " + category);
                }
            }

            response.sendRedirect("ImageDownloadServlet");
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Download images for a specific category
     * @param category Category to download images for
     */
    private void downloadImages(String category) {
        List<String> urls = IMAGE_URLS.get(category);

        if (urls == null || urls.isEmpty()) {
            return;
        }

        String basePath = getServletContext().getRealPath("/images/products/" + category);
        File baseDir = new File(basePath);

        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }

        for (int i = 0; i < urls.size(); i++) {
            String url = urls.get(i);
            String fileName = category + (i + 1) + ".jpg";

            try {
                downloadImage(url, new File(baseDir, fileName));
                System.out.println("Downloaded: " + fileName);
            } catch (IOException e) {
                System.err.println("Error downloading " + fileName + ": " + e.getMessage());
            }
        }
    }

    /**
     * Download an image from a URL and save it to a file
     * @param imageUrl URL of the image to download
     * @param destinationFile File to save the image to
     * @throws IOException If an error occurs during download
     */
    private void downloadImage(String imageUrl, File destinationFile) throws IOException {
        URL url = new URL(imageUrl);
        URLConnection connection = url.openConnection();
        connection.setRequestProperty("User-Agent", "Mozilla/5.0");

        try (InputStream in = connection.getInputStream();
             FileOutputStream out = new FileOutputStream(destinationFile)) {

            byte[] buffer = new byte[4096];
            int bytesRead;

            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
