require 'rails_helper'

describe 'User can see search results' do
  before :each do
    user = create(:user)
    moon = CelestialBodies.create(name: "Luna")
    mars = CelestialBodies.create(name: "Mars")

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    stub_request(:get, "https://skyfield-json.herokuapp.com/")
      .to_return(status: 200, body: '') # This stub is for background worker to ping skyfield app

    @image = "http://icons.iconarchive.com/icons/large-icons/large-weather/32/partly-cloudy-day-icon.png"
  end

  it 'When I submit a new search' do
    visit new_search_path

    json_mapbox_response = File.open('./spec/fixtures/mapbox_data.json')
    stub_request(:get, "https://api.mapbox.com/geocoding/v5/mapbox.places/1331%2017th%20st%20denver,%20co.json?access_token=#{ENV['MAPBOX_API_KEY']}")
    .to_return(status: 200, body: json_mapbox_response)


    json_darksky_response = File.open('./spec/fixtures/darksky_data.json')
    stub_request(:get, "https://api.darksky.net/forecast/#{ENV['DARK_SKY_API']}/39.750772,-104.996446?exclude=currently,minutely,daily,alerts,flags")
      .to_return(status: 200, body: json_darksky_response)


    json_search_index_response = File.open('./spec/fixtures/search_data.json')
    stub_request(:get, "https://skyfield-json.herokuapp.com/ephemerides?bodies=luna,mars&latitude=39.750772_N&longitude=104.996446_W")
      .to_return(status: 200, body: json_search_index_response)

    find(:css, "#bodies_[value='Luna']").set(true)
    find(:css, "#bodies_[value='Mars']").set(true)

    location = '1331 17th St Denver, CO'

    fill_in 'location', with: location

    click_button "Search"

    expect(current_path).to eq(search_index_path)
    expect(page).to have_content("My Location: 1331 17th Street, Denver, Colorado 80202, United States")

    expect(page.all('ul')[0]).to have_content('05 PM')
    expect(page.all('ul')[0]).to have_css("img[src*='#{@image}']")
    expect(page.all('ul')[0]).to have_content('Temperature: 75°')
    expect(page.all('ul')[0]).to have_content('Cloud Coverage: 32%')
    expect(page.all('ul')[0]).to have_content('Chance of Rain: 1%')
  end
end
