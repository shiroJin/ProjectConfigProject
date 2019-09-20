let icons = undefined
let launchs = undefined

function imageDisplay(res) {
  html = ''; images = JSON.parse(res)
  for (let i = 0; i < images.length; i++) {
    html += `<img src=${images[i]} style="max-width:100px;height:auto" />`
  }
  return html
}

function formData_to_json(formData) {
  jsonObj = {}
  formData.forEach((value, key) => jsonObj[key] = value);
  return jsonObj
}

$(document).ready(function() {
  $('button#submitIcon').click(function() {
    $.ajax({
      url: 'http://localhost:5000/image/upload',
      type: 'post',
      cache: false,
      data: new FormData($('#iconForm')[0]),
      processData: false,
      contentType: false
    }).done(function(res) {
      icons = JSON.parse(res)
      $('#iconDisplay').html(imageDisplay(res))
    }).fail(function(err) {
      alert('err')
    })
  })
  $('button#submitLaunch').click(function() {
    $.ajax({
      url: 'http://localhost:5000/image/upload',
      type: 'post',
      cache: false,
      data: new FormData($('#launchForm')[0]),
      processData: false,
      contentType: false
    }).done(function(res) {
      launchs = JSON.parse(res)
      $('#launchDisplay').html(imageDisplay(res))
    }).fail(function(err) {
      alert('err')
    })
  })
  $('#submit').click(function() {
    formData = new FormData($('#contentForm')[0])
    postData= formData_to_json(formData)
    if (icons) postData['icons'] = icons
    if (launchs) postData['launchs'] = launchs
    $.ajax({
      url: 'http://localhost:5000/project/newApp/butler',
      data: JSON.stringify(postData),
      type: 'post',
      contentType: 'application/json',
      dataType: 'json'
    }).done(function(data, status) {
      console.log(data)
    })
  })
})