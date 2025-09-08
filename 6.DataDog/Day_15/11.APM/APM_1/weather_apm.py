from flask import Flask, request, render_template_string
import json
import urllib.request
import os
from ddtrace import tracer, patch_all
from ddtrace.contrib.flask import TraceMiddleware

# Initialize DataDog tracing
patch_all()

app = Flask(__name__)

# Configure DataDog APM
app.config['DATADOG_TRACE'] = {
    'DEFAULT_SERVICE': os.getenv('DD_SERVICE', 'weather-app'),
    'TAGS': {'env': os.getenv('DD_ENV', 'development')}
}

# Initialize tracing middleware
traced_app = TraceMiddleware(app, tracer, service="weather-app")

def tocelcius(temp):
    """Convert Kelvin to Celsius"""
    with tracer.trace("temperature.conversion") as span:
        span.set_tag("input.temp_kelvin", temp)
        celsius = round(float(temp) - 273.16, 2)
        span.set_tag("output.temp_celsius", celsius)
        return str(celsius)

def get_weather_details(city):
    """Fetch weather data from OpenWeatherMap API"""
    with tracer.trace("weather.api_call") as span:
        span.set_tag("city", city)
        api_key = 'f37a1be289435f13fd56383c6c3a30ad'
        
        try:
            url = f'http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}'
            span.set_tag("api.url", url)
            
            # Make API request
            with tracer.trace("weather.http_request") as http_span:
                http_span.set_tag("http.method", "GET")
                http_span.set_tag("http.url", url)
                source = urllib.request.urlopen(url).read()
                http_span.set_tag("http.status_code", 200)
            
            data = json.loads(source)
            
            # Process weather data
            weather_data = {
                "country_code": data['sys']['country'],
                "coordinate": f"{data['coord']['lon']} {data['coord']['lat']}",
                "temp": f"{data['main']['temp']}k",
                "temp_cel": f"{tocelcius(data['main']['temp'])}C",
                "pressure": data['main']['pressure'],
                "humidity": data['main']['humidity'],
                "cityname": city,
            }
            
            span.set_tag("weather.country", weather_data["country_code"])
            span.set_tag("weather.temperature_celsius", weather_data["temp_cel"])
            span.set_tag("success", True)
            
            return weather_data
            
        except Exception as e:
            span.set_tag("error", True)
            span.set_tag("error.message", str(e))
            span.set_tag("success", False)
            return {"error": str(e)}

@app.route('/', methods=['GET', 'POST'])
def weather():
    """Main weather route"""
    with tracer.trace("weather.request_handler") as span:
        city = request.form.get('city', 'Delhi')
        span.set_tag("request.city", city)
        span.set_tag("request.method", request.method)
        
        # Get weather data
        data = get_weather_details(city)
        
        # Set response tags
        if 'error' in data:
            span.set_tag("response.error", True)
            span.set_tag("response.error_message", data['error'])
        else:
            span.set_tag("response.success", True)
        
        html = '''
        <!DOCTYPE html>
        <html>
        <head>
            <title>Weather App with DataDog APM</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                .container { max-width: 600px; margin: 0 auto; }
                .weather-info { background: #f0f0f0; padding: 20px; border-radius: 5px; margin-top: 20px; }
                .error { color: red; }
                input[type="text"] { padding: 10px; width: 200px; }
                input[type="submit"] { padding: 10px 20px; background: #007cba; color: white; border: none; cursor: pointer; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Weather Information (APM Enabled)</h1>
                <form method="POST">
                    <input type="text" name="city" placeholder="Enter city" value="{{city}}">
                    <input type="submit" value="Get Weather">
                </form>
                {% if data and not data.error %}
                <div class="weather-info">
                    <h2>Weather for {{data.cityname}}</h2>
                    <p><strong>Country:</strong> {{data.country_code}}</p>
                    <p><strong>Temperature:</strong> {{data.temp_cel}}</p>
                    <p><strong>Pressure:</strong> {{data.pressure}} hPa</p>
                    <p><strong>Humidity:</strong> {{data.humidity}}%</p>
                    <p><strong>Coordinates:</strong> {{data.coordinate}}</p>
                </div>
                {% elif data.error %}
                <p class="error">Error: {{data.error}}</p>
                {% endif %}
                <div style="margin-top: 30px; font-size: 12px; color: #666;">
                    <p>🔍 This application is monitored with DataDog APM</p>
                    <p>Service: weather-app | Environment: {{env}}</p>
                </div>
            </div>
        </body>
        </html>
        '''
        return render_template_string(html, data=data, city=city, env=os.getenv('DD_ENV', 'development'))

@app.route('/health')
def health_check():
    """Health check endpoint"""
    with tracer.trace("health.check") as span:
        span.set_tag("health.status", "ok")
        return {"status": "healthy", "service": "weather-app"}

if __name__ == '__main__':
    # Set DataDog environment variables if not already set
    os.environ.setdefault('DD_SERVICE', 'weather-app')
    os.environ.setdefault('DD_ENV', 'development')
    os.environ.setdefault('DD_VERSION', '1.0.0')
    
    print("Starting Weather App with DataDog APM...")
    print(f"Service: {os.getenv('DD_SERVICE')}")
    print(f"Environment: {os.getenv('DD_ENV')}")
    print(f"Version: {os.getenv('DD_VERSION')}")
    
    app.run(host='0.0.0.0', port=8000, debug=True)