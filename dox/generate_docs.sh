# This batch file generates the documentation for the MacroTween library.

# Clean the generated documentation folder, to remove any old documentation.
rm -rf generated_docs/*

# Delete any existing generated XML-format type information.
rm -f types.xml

# Build the XML-format type information.
haxe build.hxml

# Generate the documentation.
haxelib run dox -i types.xml -theme ./themes/macrotween --title "MacroTween API" -D version 1.0.0 --include "(macrotween)" -o generated_docs