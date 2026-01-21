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

furniture_users = [
  "design@atelier-wood.ru",
  "studio@loftline.ru",
  "hello@kitchenlab.ru",
  "team@modernhome.ru",
  "info@smartstorage.ru"
].map do |email|
  User.find_or_create_by!(email: email) do |user|
    user.password = "password123"
    user.password_confirmation = "password123"
    user.admin = false
  end
end

users = furniture_users + [admin]

topics = [
  "Кухня в теплых тонах для семейной квартиры",
  "Шкаф-купе с зеркалами в прихожей",
  "Гостиная с модульным диваном и системой хранения",
  "Компактная кухня для студии",
  "Детская с рабочей зоной и шкафами до потолка",
  "Спальня с мягким изголовьем и тумбами",
  "Обеденный стол из шпона с акцентными стульями",
  "Кухня в стиле минимализм с островом",
  "Гардеробная с подсветкой и стеклянными фасадами",
  "Кабинет с библиотекой и скрытыми полками"
]

descriptions = [
  "Проект для семьи с двумя детьми: много хранения, теплые фактуры и безопасная фурнитура.",
  "Шкаф-купе с верхней подсветкой, алюминиевым профилем и тихими доводчиками.",
  "Модульный диван позволяет менять конфигурацию комнаты под разные сценарии.",
  "Компактная кухня на 4,2 м с интегрированной техникой и скрытыми ручками.",
  "Рабочая зона у окна, шкафы до потолка и мягкие пастельные цвета.",
  "Текстильные панели, скрытая подсветка и мягкое изголовье в износостойкой ткани.",
  "Светлый шпон, устойчивое покрытие и удобная посадка для ежедневных ужинов.",
  "Гладкие фасады, матовые поверхности и остров с барной стойкой.",
  "Стеклянные фасады, модульные секции и умная подсветка полок.",
  "Сдержанная палитра, скрытые ниши и акустический комфорт."
]

body_parts = [
  "Мы сделали акцент на эргономику и удобный доступ к зонам хранения.",
  "Фасады выбраны в матовом исполнении — на них почти не видно отпечатков.",
  "Встроенная подсветка помогает зонировать пространство и создавать атмосферу.",
  "Фурнитура с доводчиками делает использование мебели практически бесшумным.",
  "Заказчик хотел легкие, воздушные формы — мы сохранили пропорции и свет.",
  "Для столешниц использовали устойчивые к влаге материалы с теплым оттенком.",
  "Система хранения рассчитана под сезонные вещи и крупную технику.",
  "Мы предусмотрели кабель-каналы, чтобы рабочее место оставалось чистым.",
  "В проекте применили контрастные акценты: дерево + металлы теплого цвета.",
  "Каждый блок можно заменить отдельно, без демонтажа всей мебели."
]

tags = %w[кухни шкафы-купе мягкая-мебель спальни гостиные хранение минимализм лофт массив шпон]

seed_images = [
  Rails.root.join("public/seed_images/kitchen-1.svg"),
  Rails.root.join("public/seed_images/kitchen-2.svg"),
  Rails.root.join("public/seed_images/wardrobe-1.svg"),
  Rails.root.join("public/seed_images/sofa-1.svg"),
  Rails.root.join("public/seed_images/table-1.svg"),
  Rails.root.join("public/seed_images/bed-1.svg")
]

posts = Array.new(12) do
  author = users.sample
  post = Post.create!(
    user: author,
    title: topics.sample,
    body: descriptions.sample + "\n\n" + body_parts.sample(4).join(" "),
    tag_list: tags.sample(3 + rand(3)).join(", ")
  )

  image_path = seed_images.sample
  post.images.attach(
    io: File.open(image_path),
    filename: image_path.basename.to_s,
    content_type: "image/svg+xml"
  )

  post
end

posts.each do |post|
  rand(2..5).times do
    commenter = users.sample
    Comment.create!(
      post: post,
      user: commenter,
      author: commenter.email,
      body: body_parts.sample(2).join(" "),
      tag_list: tags.sample(1 + rand(2)).join(", ")
    )
  end
end
