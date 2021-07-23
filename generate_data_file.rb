require "./app/storage.rb"

$storage = Storage.new("data.json")
$storage.generate_file
