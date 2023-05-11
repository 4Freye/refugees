import pandas as pd

from country_abbrev import *
from country_language import *
from pytrends.request import TrendReq

import os
import pycountry
import itertools

from googletrans import LANGCODES
import swifter
import requests

def translate_keywords_series(series, lang):

    series = series.str.split('+').explode()
    url = "https://translate.googleapis.com/translate_a/single"
    params = {
        "client": "gtx",
        "sl": "auto",
        "tl": lang,
        "dt": "t",
        "q": "\n".join(series.tolist())
    }
    response = requests.get(url, params=params)
    series_translated = [r[0].strip('\n').lower() for r in response.json()[0]]
    series_translated = pd.Series(index=series.index.tolist(), data=series_translated, name = series.name).to_frame().groupby(series.index)[series.name].agg(list).apply(lambda x: '+'.join(x))
    return series_translated


def translate_keywords_list(lst, lang):
    lst = [item.split('+') for item in lst]
    lst = [item for sublist in lst for item in sublist]
    url = "https://translate.googleapis.com/translate_a/single"
    params = {
        "client": "gtx",
        "sl": "auto",
        "tl": lang,
        "dt": "t",
        "q": "\n".join(lst)
    }
    response = requests.get(url, params=params)
    lst_translated = [r[0].strip('\n').lower() for r in response.json()[0]]
    return lst_translated



# Function to get ISO2 country code
def get_iso2_country_code(country_name):
    try:
        country = pycountry.countries.search_fuzzy(country_name)[0]
        return country.alpha_2
    except LookupError:
        return None



