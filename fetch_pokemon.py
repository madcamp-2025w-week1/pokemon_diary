import requests
import csv
import time

# --- CONFIGURATION ---
START_ID = 1
END_ID = 151  # Change to 494 for Gen 4
OUTPUT_FILE = 'pokemon_data_pixel.csv'

# Helper to find text in a specific language from a list
def get_lang_text(list_obj, key_name, target_lang='en'):
    for item in list_obj:
        if item['language']['name'] == target_lang:
            # .replace gets rid of weird page breaks in description text
            return item[key_name].replace('\n', ' ').replace('\f', ' ')
    return "N/A"

def fetch_data():
    print(f"Starting Pokedex Construction ({START_ID}-{END_ID})...")

    with open(OUTPUT_FILE, mode='w', newline='', encoding='utf-8-sig') as file:
        writer = csv.writer(file)
        
        # 1. Write Headers
        headers = [
            'id', 'english_name', 'korean_name', 
            'type_1', 'type_2', 
            'dex_entry_english', 'dex_entry_korean',
            'is_legendary', 'is_mythical',
            'height', 'weight', 
            'sprite_url', 'gif_url', 'icon_url'
        ]
        writer.writerow(headers)

        for poke_id in range(START_ID, END_ID + 1):
            try:
                # --- A. FETCH BASIC DATA ---
                # Contains: Types, Height, Weight
                url_basic = f"https://pokeapi.co/api/v2/pokemon/{poke_id}"
                res_basic = requests.get(url_basic)
                
                if res_basic.status_code != 200:
                    print(f"Skipping ID {poke_id}: Error fetching basic data")
                    continue
                    
                data = res_basic.json()
                
                # --- B. FETCH SPECIES DATA ---
                # Contains: Names (KR), Dex Entries, Mythical/Legendary Status
                url_species = f"https://pokeapi.co/api/v2/pokemon-species/{poke_id}"
                res_species = requests.get(url_species)
                
                if res_species.status_code != 200:
                    print(f"Skipping ID {poke_id}: Error fetching species data")
                    continue

                species = res_species.json()

                # --- C. PROCESS DATA ---
                
                # 1. Names
                # The 'name' in basic data is always lowercase-english-slug (e.g. "mr-mime")
                # We want the "Real" names from the species endpoint
                english_name = get_lang_text(species['names'], 'name', 'en')
                korean_name = get_lang_text(species['names'], 'name', 'ko')

                # 2. Types
                types = [t['type']['name'].capitalize() for t in data['types']]
                type_1 = types[0]
                type_2 = types[1] if len(types) > 1 else ""

                # 3. Traits (Convert dm -> m and hg -> kg)
                height_m = data['height'] / 10  # 10 dm = 1 m
                weight_kg = data['weight'] / 10 # 10 hg = 1 kg

                # 4. Booleans (Convert True/False to 1/0 for CSV safety)
                is_legendary = 1 if species['is_legendary'] else 0
                is_mythical = 1 if species['is_mythical'] else 0

                # 5. Dex Entries (Flavor Text)
                # We loop through flavor_text_entries to find the first EN and KO version
                dex_entry_en = "N/A"
                dex_entry_ko = "N/A"
                
                # This loop finds the first entry that matches the language
                for entry in species['flavor_text_entries']:
                    lang = entry['language']['name']
                    if lang == 'en' and dex_entry_en == "N/A":
                        dex_entry_en = entry['flavor_text'].replace('\n', ' ').replace('\f', ' ')
                    if lang == 'ko' and dex_entry_ko == "N/A":
                        dex_entry_ko = entry['flavor_text'].replace('\n', ' ').replace('\f', ' ')
                
                # 6. Construct Image URLs (Using your patterns)
                sprite_url = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{poke_id}.png"
                gif_url = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/{poke_id}.gif"
                icon_url = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/{poke_id}.png"

                # --- D. WRITE ROW ---
                writer.writerow([
                    poke_id, 
                    english_name, korean_name, 
                    dex_entry_en, dex_entry_ko,
                    type_1, type_2, 
                    height_m, weight_kg, 
                    is_legendary, is_mythical,
                    
                    sprite_url, gif_url, icon_url
                ])

                print(f"[{poke_id}/{END_ID}] Processed {english_name} / {korean_name}")

                # Be polite to the API
                time.sleep(0.05)

            except Exception as e:
                print(f"CRITICAL ERROR on ID {poke_id}: {e}")

    print(f"\nSuccess! File saved as {OUTPUT_FILE}")

if __name__ == "__main__":
    fetch_data()