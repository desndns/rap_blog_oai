// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const ensureLightbox = () => {
  let lightbox = document.querySelector(".image-lightbox")
  if (lightbox) return lightbox

  lightbox = document.createElement("div")
  lightbox.className = "image-lightbox"
  lightbox.innerHTML = '<img class="image-lightbox__img" alt="">'
  document.body.appendChild(lightbox)
  return lightbox
}

const openLightbox = (img) => {
  const lightbox = ensureLightbox()
  const lightboxImg = lightbox.querySelector(".image-lightbox__img")
  lightboxImg.src = img.currentSrc || img.src
  lightboxImg.alt = img.alt || "Image preview"
  lightbox.classList.add("image-lightbox--open")
}

const closeLightbox = () => {
  const lightbox = document.querySelector(".image-lightbox")
  if (lightbox) lightbox.classList.remove("image-lightbox--open")
}

const setupLightbox = () => {
  document.body.addEventListener("click", (event) => {
    const image = event.target.closest(".attachments__image")
    if (image) {
      event.preventDefault()
      openLightbox(image)
      return
    }

    if (event.target.closest(".image-lightbox")) {
      closeLightbox()
    }
  })

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") closeLightbox()
  })
}

document.addEventListener("turbo:load", setupLightbox)

const isInteractiveTarget = (target) =>
  target.closest("a, button, input, textarea, select, label, summary, details, .button")

const setupPostCardNavigation = () => {
  document.body.addEventListener("click", (event) => {
    const card = event.target.closest(".post-card")
    if (!card || isInteractiveTarget(event.target)) return

    const url = card.dataset.postUrl
    if (url) {
      event.preventDefault()
      window.location.assign(url)
    }
  })

  document.body.addEventListener("keydown", (event) => {
    if (event.key !== "Enter" && event.key !== " ") return
    const card = event.target.closest(".post-card")
    if (!card) return
    if (isInteractiveTarget(event.target)) return

    const url = card.dataset.postUrl
    if (url) {
      event.preventDefault()
      window.location.assign(url)
    }
  })
}

document.addEventListener("turbo:load", setupPostCardNavigation)
