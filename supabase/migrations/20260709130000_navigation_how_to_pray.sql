-- Align More menu Learn section with Figma (How to Pray replaces Wudu in menu)

UPDATE public.navigation_menu_items
SET label = 'How to Pray',
    route = '/how-to-pray',
    icon = 'self_improvement',
    updated_at = now()
WHERE section = 'learn' AND label = 'Wudu Guide';
