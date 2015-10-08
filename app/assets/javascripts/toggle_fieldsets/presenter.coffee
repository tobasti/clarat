# Toggle fieldset subsections by clicking on fieldset headlines
# but only in mobile context
Clarat.ToggleFieldsets = {}
class Clarat.ToggleFieldsets.Presenter extends ActiveScript.Presenter

  CALLBACKS:
    '.filter-form__fieldset__headline':
      click: 'handleClick'

  handleClick: (e) =>

    if ($(window).width() < 401)
      $(e.target).next(".filter-form__fieldset__wrapper").toggleClass("is-visible")

$(document).on 'ready', ->
  new Clarat.ToggleFieldsets.Presenter
