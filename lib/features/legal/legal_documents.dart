import 'package:flutter/material.dart';

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.summary,
    required this.updatedAt,
    required this.sections,
  });

  final String title;
  final String summary;
  final String updatedAt;
  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
}

const termsOfUseDocument = LegalDocument(
  title: 'Conditions d\'utilisation',
  summary:
      'Ces conditions encadrent l\'usage de Pointa, du compte employé mobile et des fonctions de pointage mises à disposition par l\'entreprise.',
  updatedAt: '11 avril 2026',
  sections: <LegalSection>[
    LegalSection(
      title: '1. Objet',
      paragraphs: <String>[
        'Pointa permet la gestion des présences, des horaires et du pointage des employés au sein d\'une organisation.',
        'L\'application mobile employé est destinée au pointage, à la consultation des informations de présence et aux actions de sécurité liées au compte.',
      ],
    ),
    LegalSection(
      title: '2. Compte utilisateur',
      paragraphs: <String>[
        'Le compte employé est créé et administré par l\'entreprise ou son représentant autorisé.',
        'L\'utilisateur s\'engage à ne pas partager ses identifiants et à utiliser exclusivement le compte qui lui a été attribué.',
      ],
    ),
    LegalSection(
      title: '3. Pointage et localisation',
      paragraphs: <String>[
        'Le pointage peut utiliser la position du terminal afin de vérifier la cohérence avec la zone autorisée de travail.',
        'La précision dépend du GPS, du réseau, du terminal et de l\'environnement. Une imprécision technique peut empêcher ou retarder la validation d\'un pointage.',
      ],
    ),
    LegalSection(
      title: '4. Sécurité',
      paragraphs: <String>[
        'Pointa peut appliquer des mesures telles que le verrouillage local, le contrôle de session ou l\'association du compte à un appareil autorisé.',
        'L\'utilisateur doit protéger son appareil et signaler tout usage non autorisé à son responsable.',
      ],
    ),
    LegalSection(
      title: '5. Responsabilités',
      paragraphs: <String>[
        'L\'entreprise reste responsable de la configuration de ses sites, horaires, règles internes et procédures de validation.',
        'Pointa est fourni avec une obligation de moyens et ne remplace pas les contrôles internes de l\'organisation.',
      ],
    ),
  ],
);

const privacyPolicyDocument = LegalDocument(
  title: 'Politique de confidentialité',
  summary:
      'Cette politique décrit les données utilisées dans Pointa, pourquoi elles sont traitées et les mesures de protection appliquées.',
  updatedAt: '11 avril 2026',
  sections: <LegalSection>[
    LegalSection(
      title: '1. Données traitées',
      paragraphs: <String>[
        'Pointa peut traiter le nom, le prénom, le téléphone, l\'e-mail, les informations de présence, les horaires, les sites et certains journaux techniques de session.',
        'Lors d\'un pointage, l\'application peut traiter la localisation, l\'horodatage et la précision associée si cela est nécessaire au contrôle demandé par l\'entreprise.',
      ],
    ),
    LegalSection(
      title: '2. Finalités',
      paragraphs: <String>[
        'Les données sont utilisées pour l\'authentification, le contrôle d\'accès, la gestion des présences, la génération de rapports et la prévention de la fraude.',
        'Elles peuvent aussi servir à des besoins d\'audit, de sécurité opérationnelle et d\'administration interne du service.',
      ],
    ),
    LegalSection(
      title: '3. Accès aux données',
      paragraphs: <String>[
        'Chaque utilisateur n\'accède qu\'aux données compatibles avec son rôle et les règles configurées par l\'organisation cliente.',
        'L\'entreprise cliente peut consulter les données nécessaires à la gestion de ses collaborateurs et de ses sites.',
      ],
    ),
    LegalSection(
      title: '4. Conservation et sécurité',
      paragraphs: <String>[
        'Les données sont conservées pendant la durée utile au service, aux obligations légales applicables et aux exigences de sécurité ou de traçabilité.',
        'Pointa applique des mesures techniques et organisationnelles raisonnables, sans pouvoir garantir un risque nul.',
      ],
    ),
    LegalSection(
      title: '5. Demandes',
      paragraphs: <String>[
        'Les demandes de mise à jour, de correction ou de suppression doivent suivre le circuit défini par l\'entreprise cliente ou son administrateur Pointa.',
      ],
    ),
  ],
);

Future<void> showLegalDocumentSheet(
  BuildContext context, {
  required LegalDocument document,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.88,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F5FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D4EA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: <Widget>[
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A2550),
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      document.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: const Color(0xFF6F7592),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dernière mise à jour : ${document.updatedAt}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8E93AA),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),
                    for (final section in document.sections) ...<Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFE4E1F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              section.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A2550),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            for (final paragraph in section.paragraphs) ...<Widget>[
                              Text(
                                paragraph,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      height: 1.55,
                                      color: const Color(0xFF5E6583),
                                    ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
