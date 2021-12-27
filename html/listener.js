(function () {
  $('.recipient').hide()
  $('#order-sheet').hide()
  window.addEventListener('message', function(event) {
    console.log(event)
    const item = event.data
    if (item.action === 'open') {
      const template = (dish, amount) => `<li><span>${dish}</span><span>${amount}x</span></li>`

      if (item.sheet.type !== 'Allgemein') {
        document.querySelector('.recipient').innerHTML = `Bestellung geht an die ${item.sheet.type}`
        $('.recipient').show()
      } else {
        $('.recipient').hide()
      }

      for (const [key, value] of Object.entries(item.sheet.orders)) {
        if (value > 0) {
          document.querySelector('ul').innerHTML += template(key, value)
        }
      }
      $('#order-sheet').show()
    } else {
      $('#order-sheet').hide()
      document.querySelector('ul').innerHTML = ''
    }
  }, false)
})();