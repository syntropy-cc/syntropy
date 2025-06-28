// coloca tipagem .json para poder importar
import meta from "./summary.json"
import cover from "./course-cover.png"

export default {
  ...meta,
  slug: "python-basics", // ou meta.slug
  cover,                 // string gerada pelo bundle
}
