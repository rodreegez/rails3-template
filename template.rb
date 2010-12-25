# Remove unnecessary files
remove_file "README"
remove_file "public/index.html"
remove_file "public/favicon.ico"
remove_file "public/robots.txt"
remove_file "public/index.html"
remove_file "public/images/rails.png"

# Create README
file 'README', <<-README
#{app_name.humanize}
README
