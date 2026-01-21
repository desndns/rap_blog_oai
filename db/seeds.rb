# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "securerandom"

admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

admin = User.find_or_create_by!(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.admin = true
end

names = %w[Lex Rima Jazz Echo Nova Blaze Vibe Kato Mira Zed Lyra]
topics = [
  "Flow and cadence",
  "Storytelling bars",
  "Studio session notes",
  "Sampling deep cuts",
  "Live show recap",
  "Album review",
  "Cypher highlights",
  "Lyric breakdown"
]
tags = %w[boom-bap trap freestyle review stage studio bars hooks]
sentences = [
  "The hook lands with a clean pocket and a late snare.",
  "Drums knock but leave room for the bass to breathe.",
  "Bars are tight, no filler, just straight momentum.",
  "The bridge switches up the rhythm and it works.",
  "Punchlines are stacked with a playful edge.",
  "The mix keeps the vocals front without washing the beat.",
  "This track feels like a midnight drive through the city.",
  "There is a calm confidence in every line.",
  "The cadence flips twice and still feels smooth.",
  "The outro leaves you wanting another verse."
]

def random_paragraph(sentences, count)
  Array.new(count) { sentences.sample }.join(" ")
end

users = Array.new(6) do
  User.create!(
    email: "user-#{SecureRandom.hex(3)}@example.com",
    password: "password123",
    password_confirmation: "password123",
    admin: false
  )
end

users << admin

posts = Array.new(12) do
  author = users.sample
  Post.create!(
    user: author,
    title: "#{topics.sample} — #{SecureRandom.hex(2).upcase}",
    body: random_paragraph(sentences, 4 + rand(4)),
    tag_list: tags.sample(2 + rand(3)).join(", ")
  )
end

posts.each do |post|
  rand(2..6).times do
    commenter = users.sample
    Comment.create!(
      post: post,
      user: commenter,
      author: commenter.email,
      body: random_paragraph(sentences, 2 + rand(3)),
      tag_list: tags.sample(1 + rand(2)).join(", ")
    )
  end
end
