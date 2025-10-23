// Page Privacy Policy pour Next.js
// À placer dans: app/privacy/page.tsx (Next.js 13+ App Router)
// ou pages/privacy.tsx (Next.js Pages Router)

import React from 'react';

export const metadata = {
  title: 'Politique de confidentialité | Pièces d\'Occasion',
  description: 'Politique de confidentialité de l\'application Pièces d\'Occasion',
};

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <header className="bg-gradient-to-r from-blue-600 to-blue-700 text-white py-16">
        <div className="container mx-auto px-4">
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            Politique de confidentialité
          </h1>
          <p className="text-xl text-blue-100">
            Dernière mise à jour : 22 octobre 2025
          </p>
        </div>
      </header>

      {/* Content */}
      <main className="container mx-auto px-4 py-12 max-w-4xl">
        <Section
          title="1. Introduction"
          content="Bienvenue sur Pièces d'Occasion. Nous respectons votre vie privée et nous nous engageons à protéger vos données personnelles. Cette politique de confidentialité vous informe sur la manière dont nous collectons et traitons vos données lorsque vous utilisez notre application."
        />

        <Section
          title="2. Données collectées"
          content={
            <div>
              <p className="mb-4">Nous collectons les données suivantes :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>
                  <strong>Informations de compte :</strong> nom, prénom, email,
                  téléphone
                </li>
                <li>
                  <strong>Localisation :</strong> votre position géographique
                  (uniquement lorsque vous utilisez l'app) pour vous proposer des
                  pièces près de chez vous
                </li>
                <li>
                  <strong>Photos :</strong> images des pièces automobiles que vous
                  publiez
                </li>
                <li>
                  <strong>Informations sur les pièces :</strong> marque, modèle,
                  année du véhicule
                </li>
                <li>
                  <strong>Données de messagerie :</strong> vos conversations avec
                  les vendeurs/acheteurs
                </li>
              </ul>
            </div>
          }
        />

        <Section
          title="3. Utilisation des données"
          content={
            <div>
              <p className="mb-4">Vos données sont utilisées pour :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Créer et gérer votre compte</li>
                <li>Publier et rechercher des annonces de pièces automobiles</li>
                <li>Vous mettre en relation avec d'autres utilisateurs</li>
                <li>Améliorer nos services</li>
                <li>Vous envoyer des notifications importantes</li>
              </ul>
            </div>
          }
        />

        <Section
          title="4. Partage des données"
          content={
            <div>
              <p className="mb-4">
                Vos données ne sont <strong>JAMAIS vendues</strong> à des tiers.
              </p>
              <p className="mb-4">Nous partageons vos données uniquement :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>
                  Avec les autres utilisateurs dans le cadre des annonces (nom,
                  localisation approximative)
                </li>
                <li>
                  Avec nos prestataires techniques (Supabase pour l'hébergement)
                </li>
                <li>Si requis par la loi</li>
              </ul>
            </div>
          }
        />

        <Section
          title="5. Localisation"
          content={
            <div>
              <p className="mb-4">
                Nous utilisons votre localisation UNIQUEMENT lorsque vous utilisez
                l'application (permission "When In Use").
              </p>
              <p className="mb-4">La localisation sert à :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Vous proposer des pièces près de chez vous</li>
                <li>Afficher votre ville sur vos annonces</li>
              </ul>
              <p className="mt-4">
                Vous pouvez désactiver la localisation à tout moment dans les
                paramètres de votre appareil.
              </p>
            </div>
          }
        />

        <Section
          title="6. Photos et médias"
          content={
            <div>
              <p className="mb-4">
                Nous accédons à votre galerie photo uniquement pour vous permettre
                de :
              </p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Sélectionner des photos de pièces pour vos annonces</li>
                <li>Prendre des photos directement depuis l'app</li>
              </ul>
              <p className="mt-4">
                Les photos sont stockées de manière sécurisée et ne sont visibles
                que dans le contexte de vos annonces.
              </p>
            </div>
          }
        />

        <Section
          title="7. Notifications"
          content={
            <div>
              <p className="mb-4">
                Nous utilisons OneSignal pour envoyer des notifications push.
              </p>
              <p className="mb-4">Les notifications vous informent de :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Nouveaux messages</li>
                <li>Réponses à vos annonces</li>
                <li>Nouvelles pièces correspondant à vos recherches</li>
              </ul>
              <p className="mt-4">
                Vous pouvez désactiver les notifications dans les paramètres de
                votre appareil.
              </p>
            </div>
          }
        />

        <Section
          title="8. Sécurité"
          content={
            <div>
              <p className="mb-4">
                Vos données sont stockées de manière sécurisée chez Supabase
                (hébergement européen conforme RGPD).
              </p>
              <p className="mb-4">Nous utilisons :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Chiffrement SSL/TLS pour toutes les communications</li>
                <li>Authentification sécurisée</li>
                <li>Accès limité aux données personnelles</li>
              </ul>
            </div>
          }
        />

        <Section
          title="9. Vos droits"
          content={
            <div>
              <p className="mb-4">Conformément au RGPD, vous avez le droit de :</p>
              <ul className="list-disc pl-6 space-y-2">
                <li>Accéder à vos données</li>
                <li>Corriger vos données</li>
                <li>Supprimer votre compte et toutes vos données</li>
                <li>Exporter vos données</li>
                <li>Vous opposer au traitement de vos données</li>
              </ul>
              <p className="mt-4">
                Pour exercer ces droits, contactez-nous à :{' '}
                <a
                  href="mailto:contact@pieceautoenligne.fr"
                  className="text-blue-600 hover:text-blue-700 underline"
                >
                  contact@pieceautoenligne.fr
                </a>
              </p>
            </div>
          }
        />

        <Section
          title="10. Cookies et tracking"
          content={
            <div>
              <p className="mb-4">
                Notre application <strong>N'UTILISE PAS</strong> de cookies de
                tracking publicitaire.
              </p>
              <p>
                Nous utilisons uniquement des données techniques nécessaires au
                fonctionnement de l'app (préférences utilisateur, session).
              </p>
            </div>
          }
        />

        <Section
          title="11. Modifications"
          content="Nous pouvons modifier cette politique de confidentialité. Vous serez informé de tout changement important par notification dans l'application."
        />

        <Section
          title="12. Contact"
          content={
            <div>
              <p className="mb-4">
                Pour toute question concernant cette politique de confidentialité :
              </p>
              <p>
                <strong>Email :</strong>{' '}
                <a
                  href="mailto:contact@pieceautoenligne.fr"
                  className="text-blue-600 hover:text-blue-700 underline"
                >
                  contact@pieceautoenligne.fr
                </a>
              </p>
              <p className="mt-2">
                <strong>Dernière mise à jour :</strong> 22 octobre 2025
              </p>
            </div>
          }
        />

        {/* CTA Section */}
        <div className="mt-16 bg-blue-50 border border-blue-200 rounded-lg p-8 text-center">
          <h3 className="text-2xl font-bold text-gray-900 mb-4">
            Des questions ?
          </h3>
          <p className="text-gray-700 mb-6">
            Notre équipe est à votre disposition pour répondre à vos questions
            concernant la protection de vos données.
          </p>
          <a
            href="mailto:contact@pieceautoenligne.fr"
            className="inline-block bg-blue-600 hover:bg-blue-700 text-white font-semibold px-8 py-3 rounded-lg transition-colors"
          >
            Nous contacter
          </a>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-100 border-t border-gray-200 py-8 mt-16">
        <div className="container mx-auto px-4 text-center text-gray-600">
          <p>
            &copy; 2025 Pièces d'Occasion. Tous droits réservés.
          </p>
          <div className="mt-4 space-x-4">
            <a
              href="/terms"
              className="text-blue-600 hover:text-blue-700 underline"
            >
              Conditions d'utilisation
            </a>
            <a
              href="/privacy"
              className="text-blue-600 hover:text-blue-700 underline"
            >
              Politique de confidentialité
            </a>
            <a
              href="mailto:contact@pieceautoenligne.fr"
              className="text-blue-600 hover:text-blue-700 underline"
            >
              Contact
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

// Section component for better organization
interface SectionProps {
  title: string;
  content: React.ReactNode;
}

function Section({ title, content }: SectionProps) {
  return (
    <section className="mb-12">
      <h2 className="text-2xl md:text-3xl font-bold text-gray-900 mb-4">
        {title}
      </h2>
      <div className="text-gray-700 leading-relaxed">
        {typeof content === 'string' ? <p>{content}</p> : content}
      </div>
    </section>
  );
}
