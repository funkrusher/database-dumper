from faker import Faker

fake = Faker()

def sanitize_email(value):
    return fake.email(domain='example.com')