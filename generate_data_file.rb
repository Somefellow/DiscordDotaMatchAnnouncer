# frozen_string_literal: true

require "./app/storage"

$storage = Storage.new("data.json")
$storage.generate_file
