import requests
import csv
import time

# --- CONFIGURATION ---
START_ID = 1
END_ID = 151  # Change to 494 for Gen 4
# Output Files
FILE_CORE = 'pokemon_core.csv'
FILE_RETRO = 'pokemon_sprites_retro.csv'
FILE_MODERN = 'pokemon_sprites_modern.csv'

# Helper to find text in a specific language from a list
def get_lang_text(list_obj, key_name, target_lang='en'):
    for item in list_obj:
        if item['language']['name'] == target_lang:
            return item[key_name].replace('\n', ' ').replace('\f', ' ')
    return "N/A"

def fetch_data():
    print(f"Starting Pokedex Construction ({START_ID}-{END_ID})...")

    with open(FILE_CORE, mode='w', newline='', encoding='utf-8-sig') as f_core, \
         open(FILE_RETRO, mode='w', newline='', encoding='utf-8-sig') as f_retro, \
         open(FILE_MODERN, mode='w', newline='', encoding='utf-8-sig') as f_modern:
        
        writer_core = csv.writer(f_core)
        writer_retro = csv.writer(f_retro)
        writer_modern = csv.writer(f_modern)
        
        # 1. Write Headers
        # Core Info (Added icon_url here)
        writer_core.writerow([
            'id', 'english_name', 'korean_name', 
            'type_1', 'type_2', 
            'dex_entry_english', 'dex_entry_korean',
            'is_legendary', 'is_mythical',
            'height', 'weight',
            'icon_url' 
        ])
        
        # Retro Sprites (Removed icon_url)
        writer_retro.writerow(['id', 'sprite_url', 'gif_url'])
        
        # Modern Sprites
        writer_modern.writerow(['id', 'sprite_url', 'gif_url'])

        for poke_id in range(START_ID, END_ID + 1):
            try:
                # --- A. FETCH BASIC DATA ---
                url_basic = f"https://pokeapi.co/api/v2/pokemon/{poke_id}"
                res_basic = requests.get(url_basic)
                
                if res_basic.status_code != 200:
                    print(f"Skipping ID {poke_id}: Error fetching basic data")
                    continue
                    
                data = res_basic.json()
                
                # --- B. FETCH SPECIES DATA ---
                url_species = f"https://pokeapi.co/api/v2/pokemon-species/{poke_id}"
                res_species = requests.get(url_species)
                
                if res_species.status_code != 200:
                    print(f"Skipping ID {poke_id}: Error fetching species data")
                    continue

                species = res_species.json()

                # --- C. PROCESS DATA ---
                
                # 1. Names
                english_name = get_lang_text(species['names'], 'name', 'en')
                korean_name = get_lang_text(species['names'], 'name', 'ko')

                # 2. Types
                types = [t['type']['name'].capitalize() for t in data['types']]
                type_1 = types[0]
                type_2 = types[1] if len(types) > 1 else ""

                # 3. Traits
                height_m = data['height'] / 10
                weight_kg = data['weight'] / 10

                # 4. Booleans
                is_legendary = 1 if species['is_legendary'] else 0
                is_mythical = 1 if species['is_mythical'] else 0

                # 5. Dex Entries
                dex_entry_en = "N/A"
                dex_entry_ko = "N/A"
                
                for entry in species['flavor_text_entries']:
                    lang = entry['language']['name']
                    if lang == 'en' and dex_entry_en == "N/A":
                        dex_entry_en = entry['flavor_text'].replace('\n', ' ').replace('\f', ' ')
                    if lang == 'ko' and dex_entry_ko == "N/A":
                        dex_entry_ko = entry['flavor_text'].replace('\n', ' ').replace('\f', ' ')
                
                # --- D. GENERATE URLS ---

                # Core Shared Asset (Icon)
                icon_url = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-viii/icons/{poke_id}.png"

                # Retro (Gen 5 Black/White)
                retro_sprite = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/{poke_id}.png"
                retro_gif = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/{poke_id}.gif"

                # Modern (Home / Showdown)
                modern_sprite = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{poke_id}.png"
                modern_gif = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/{poke_id}.gif"

                # --- E. WRITE ROWS ---
                
                # Core (Now includes icon_url)
                writer_core.writerow([
                    poke_id, 
                    english_name, korean_name, 
                    type_1, type_2, 
                    dex_entry_en, dex_entry_ko,
                    is_legendary, is_mythical,
                    height_m, weight_kg,
                    icon_url
                ])

                # Retro
                writer_retro.writerow([poke_id, retro_sprite, retro_gif])

                # Modern
                writer_modern.writerow([poke_id, modern_sprite, modern_gif])

                print(f"[{poke_id}/{END_ID}] Processed {english_name}")

                time.sleep(0.05)

            except Exception as e:
                print(f"CRITICAL ERROR on ID {poke_id}: {e}")

    print(f"\nSuccess! Files saved:\n1. {FILE_CORE}\n2. {FILE_RETRO}\n3. {FILE_MODERN}")

if __name__ == "__main__":
    fetch_data()