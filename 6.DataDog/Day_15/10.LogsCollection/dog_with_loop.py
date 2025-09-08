if __name__ == '__main__':
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    import undetected_chromedriver as uc
    import logging
    from pythonjsonlogger import jsonlogger 
    import itertools
    from time import sleep
    import datetime
    
    options = uc.ChromeOptions()
    options.add_argument("--incognito")
    driver = uc.Chrome(executable_path="chromedriver.exe", options=options)
    driver.maximize_window()
    
    # Logging configuration
    logger = logging.getLogger()

    logHandler = logging.FileHandler(filename='/var/log/datadog/python_app.log')
    formatter = jsonlogger.JsonFormatter()
    logHandler.setFormatter(formatter)
    logger.addHandler(logHandler)
    logger.setLevel(logging.INFO)
    
    try:
        driver.get("https://www.amazon.com/")
        driver.find_element(By.XPATH, value="//div[contains(@class,'product')]")
        logger.info('Product found successfully', extra={'referral_code': '79vn4et', 'status': 'success'})
        
    except Exception as e:
        logger.error('Starting continuous monitoring due to product not found', extra={
            'referral_code': '79vn4et', 
            'error': str(e),
            'status': 'monitoring_started'
        })
        
        count = 0
        for x in itertools.repeat(1): 
            count += 1
            logger.info('Product monitoring attempt', extra={
                'referral_code': '79vn4et',
                'attempt': count,
                'timestamp': datetime.datetime.now().isoformat(),
                'status': 'monitoring'
            })
            sleep(5)  # Changed to 5 seconds to avoid spam
            
            # Break after 10 attempts for demo
            if count >= 10:
                logger.info('Monitoring completed', extra={
                    'referral_code': '79vn4et',
                    'total_attempts': count,
                    'status': 'completed'
                })
                break
    
    driver.quit()