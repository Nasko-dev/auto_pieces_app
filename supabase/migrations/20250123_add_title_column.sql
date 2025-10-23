-- Migration: Ajout du champ title pour les annonces
-- Date: 23 janvier 2025
-- Description: Permet aux vendeurs de personnaliser le titre de leurs annonces

-- Ajouter la colonne title (optionnelle)
ALTER TABLE part_advertisements
ADD COLUMN IF NOT EXISTS title TEXT;

-- Ajouter un commentaire pour la documentation
COMMENT ON COLUMN part_advertisements.title IS 'Titre personnalisé de l''annonce (optionnel, par défaut construit depuis les infos véhicule)';

-- Créer un index pour les recherches sur le titre
CREATE INDEX IF NOT EXISTS idx_part_advertisements_title
ON part_advertisements(title)
WHERE title IS NOT NULL;
