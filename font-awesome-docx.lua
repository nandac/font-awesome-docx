--- font-awesome-docx.lua – Sets the font of Font Awesome Icons in DOCX
---
--- Author: Nandakumaar Chandrasekhar
--- Copyright: © 2021–2022 Contributors
--- License: MIT – see LICENSE for details

-- Please create the FontAwesomeRegular, FontAwesomeSolid and
-- FontAwesomeBrands styles in the reference docx before using this filter
-- as stated in the README

-- Makes sure users know if their pandoc version is too old for this
-- filter.
PANDOC_VERSION:must_be_at_least '2.17'

-- This function is called for every span element in the document.
-- If the span element has one of the custom styles of 'fa-regular',
-- 'fa-solid' or 'fa-brands' the style of 'FontAwesomeRegular',
-- 'FontAwesomeSolid' or 'FontAwesomeBrands' defined in the reference doc
-- is added as an attribute to the span.
function Span(span)
  if span.classes:includes "fa-regular" then
      span.attributes['custom-style'] = "FontAwesomeRegular"
      return span
  elseif span.classes:includes "fa-solid" then
      span.attributes['custom-style'] = "FontAwesomeSolid"
      return span
  elseif span.classes:includes "fa-brands" then
      span.attributes['custom-style'] = "FontAwesomeBrands"
      return span
  end
  return nil
end
