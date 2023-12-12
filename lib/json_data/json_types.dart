import 'package:collection/collection.dart';
import 'package:bookoscope/render/accordion.dart';
import 'package:bookoscope/render/horizontal_key_values.dart';
import 'package:bookoscope/render/internal_column.dart';
import 'package:bookoscope/render/labeled_link_accordion.dart';
import 'package:bookoscope/render/labeled_list_accordion.dart';
import 'package:bookoscope/render/labeled_search_links.dart';
import 'package:bookoscope/render/link.dart';
import 'package:bookoscope/render/name_description.dart';
import 'package:bookoscope/render/paragraph.dart';
import 'package:bookoscope/render/section_label.dart';
import 'package:bookoscope/render/vertical_key_values.dart';
import 'package:bookoscope/search/search_manager.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_types.g.dart';

@JsonSerializable()
class CJsonRoot implements CHasSearchables {
  List<CJsonType> types;
  List<CJsonFlavor> flavors;
  List<CJsonDescriptor> descriptors;
  List<CJsonFocus> foci;
  List<CJsonAbility> abilities;
  List<CJsonCypher> cyphers;

  @JsonKey(name: "cypher_tables")
  List<CJsonRollTable> cypherTables;
  List<CJsonArtifact> artifacts;
  List<CJsonCreature> creatures;
  List<CJsonEquipment> equipment;

  CJsonRoot({
    required this.types,
    required this.flavors,
    required this.descriptors,
    required this.foci,
    required this.abilities,
    required this.cyphers,
    required this.cypherTables,
    required this.artifacts,
    required this.creatures,
    required this.equipment,
  });

  factory CJsonRoot.fromJson(Map<String, dynamic> json) =>
      _$CJsonRootFromJson(json);

  @override
  List<CSearchableCategory> get searchables => [
        CSearchableCategory(category: "Abilities", searchables: abilities),
        CSearchableCategory(category: "Artifacts", searchables: artifacts),
        CSearchableCategory(category: "Creatures", searchables: creatures),
        CSearchableCategory(category: "Cyphers", searchables: cyphers),
        CSearchableCategory(category: "Descriptors", searchables: descriptors),
        CSearchableCategory(category: "Equipment", searchables: equipment),
        CSearchableCategory(category: "Flavors", searchables: flavors),
        CSearchableCategory(category: "Foci", searchables: foci),
        CSearchableCategory(category: "Types", searchables: types),
      ];
}

@JsonSerializable()
class CJsonAbility implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => description;

  String name;
  int? cost;
  List<String> pool;

  @JsonKey(name: "additional_cost")
  String? additionalCost;

  @JsonKey(name: "cost_rendered")
  String costRendered;

  String? tier;
  List<String> category;
  String description;
  List<String> references;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonAbility({
    required this.name,
    required this.cost,
    required this.pool,
    required this.additionalCost,
    required this.costRendered,
    required this.tier,
    required this.category,
    required this.description,
    required this.references,
  }) : searchTextList = [
          "Name: $name",
          description,
          if (cost != null) "Cost: $costRendered",
          if (tier != null) "Tier: $tier",
          if (category.isNotEmpty) ...category.map((c) => "Category: $c"),
          if (references.isNotEmpty) "Used by: ${references.join(", ")}"
        ];

  factory CJsonAbility.fromJson(Map<String, dynamic> json) =>
      _$CJsonAbilityFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderVerticalKeyValues([
        CNameDescription("Cost", cost == null ? "None" : costRendered),
        if (tier != null) CNameDescription("Tier", tier!),
      ]),
      CRenderParagraph(description),
      if (category.isNotEmpty)
        CRenderLinksParagraph(
          label: category.length == 1 ? "Category" : "Categories",
          textQueries: category
              .map((cat) => CSearchQueryLink(cat, "Category: $cat"))
              .toList(),
        ),
      if (references.isNotEmpty)
        CRenderLinksParagraph(
          label: "Used by",
          textQueries: references
              .map((ref) =>
                  CResultLink(ref, resultCategory: null, resultName: ref))
              .toList(),
        ),
    ];
  }
}

@JsonSerializable()
class CJsonAbilityRef implements CSearchableItem {
  String name;
  int tier;
  bool preselected;

  @override
  @JsonKey(includeFromJson: false)
  String searchText;

  CJsonAbilityRef({
    required this.name,
    required this.tier,
    required this.preselected,
  }) : searchText =
            "Ability: $name (Tier $tier, ${preselected ? "preselected" : "optional"})";

  factory CJsonAbilityRef.fromJson(Map<String, dynamic> json) =>
      _$CJsonAbilityRefFromJson(json);
}

@JsonSerializable()
class CJsonBasicAbility implements CSearchableItem {
  String name;
  String description;

  @override
  @JsonKey(includeFromJson: false)
  String searchText;

  CJsonBasicAbility({
    required this.name,
    required this.description,
  }) : searchText = "$name: $description";

  factory CJsonBasicAbility.fromJson(Map<String, dynamic> json) =>
      _$CJsonBasicAbilityFromJson(json);
}

@JsonSerializable()
class CJsonType implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => statPool.entries
      .map((entry) => "${entry.key}: ${entry.value}")
      .join(" | ");

  String name;
  List<CJsonBasicAbility> intrusions;

  @JsonKey(name: "stat_pool")
  Map<String, int> statPool;

  CJsonRollTable background;

  @JsonKey(name: "special_abilities_per_tier")
  List<CJsonSpecialAbilitiesAmount> specialAbilitiesPerTier;
  List<CJsonBasicAbility> abilities;

  @JsonKey(name: "special_abilities")
  List<CJsonAbilityRef> specialAbilities;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonType({
    required this.name,
    required this.intrusions,
    required this.statPool,
    required this.background,
    required this.specialAbilitiesPerTier,
    required this.abilities,
    required this.specialAbilities,
  }) : searchTextList = [
          "Name: $name",
          ...statPool.entries.map((kvp) => "${kvp.key}: ${kvp.value}"),
          ...abilities.map((a) => a.searchText),
          ...specialAbilities.map((s) => s.searchText),
          ...intrusions.map((i) => i.searchText),
          ...specialAbilitiesPerTier.map((s) => s.searchText),
        ];

  factory CJsonType.fromJson(Map<String, dynamic> json) =>
      _$CJsonTypeFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderHorizontalKeyValues(
        statPool.entries
            .map<CNameDescription>(
                (entry) => CNameDescription(entry.key, entry.value.toString()))
            .toList(),
      ),
      CRenderLabeledListAccordion(
        abilities.map((a) => CNameDescription(a.name, a.description)),
        label: "Traits",
      ),
      CRenderLabeledListAccordion(
        intrusions.map((i) => CNameDescription(i.name, i.description)),
        label: "Intrusions",
      ),
      ...specialAbilitiesPerTier.map(
        (tierAmount) => CRenderLabeledResultLinkAccordion(
          label: "Tier ${tierAmount.tier} Abilities",
          innerLabel: "Take ${tierAmount.specialAbilities}:",
          links: specialAbilities
              .where((a) => a.tier == tierAmount.tier)
              .sorted((a, b) => a.preselected == b.preselected
                  ? 0
                  : a.preselected
                      ? -1
                      : 1)
              .map((a) => CResultLink(
                    "${a.name}${a.preselected ? " (preselected)" : ""}",
                    resultCategory: "Abilities",
                    resultName: a.name,
                  ))
              .toList(),
        ),
      ),
    ];
  }
}

@JsonSerializable()
class CJsonSpecialAbilitiesAmount implements CSearchableItem {
  int tier;

  @JsonKey(name: "special_abilities")
  int specialAbilities;

  @override
  @JsonKey(includeFromJson: false)
  String searchText;

  CJsonSpecialAbilitiesAmount({
    required this.tier,
    required this.specialAbilities,
  }) : searchText = "$specialAbilities special abilities at tier $tier";

  factory CJsonSpecialAbilitiesAmount.fromJson(Map<String, dynamic> json) =>
      _$CJsonSpecialAbilitiesAmountFromJson(json);
}

@JsonSerializable()
class CJsonFlavor implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => "";

  String name;
  List<CJsonAbilityRef> abilities;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonFlavor({
    required this.name,
    required this.abilities,
  }) : searchTextList = [
          "Name: $name",
          ...abilities.map((a) => a.searchText),
        ];

  factory CJsonFlavor.fromJson(Map<String, dynamic> json) =>
      _$CJsonFlavorFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return abilities
        .groupListsBy((a) => a.tier)
        .entries
        .map(
          (grp) => CRenderLabeledResultLinkAccordion(
            label: "Tier ${grp.key} Abilities",
            links: grp.value
                .sorted((a, b) => a.preselected == b.preselected
                    ? 0
                    : a.preselected
                        ? -1
                        : 1)
                .map((a) => CResultLink(
                      "${a.name}${a.preselected ? " (preselected)" : ""}",
                      resultCategory: "Abilities",
                      resultName: a.name,
                    ))
                .toList(),
          ),
        )
        .toList();
  }
}

@JsonSerializable()
class CJsonDescriptor implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => description;

  String name;
  String description;
  List<CJsonBasicAbility> characteristics;
  List<String> links;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonDescriptor({
    required this.name,
    required this.description,
    required this.characteristics,
    required this.links,
  }) : searchTextList = [
          "Name: $name",
          description,
          ...characteristics.map((c) => c.searchText),
          ...links.map((link) => "Link: $link"),
        ];

  factory CJsonDescriptor.fromJson(Map<String, dynamic> json) =>
      _$CJsonDescriptorFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderParagraph(description),
      CRenderLabeledListAccordion(
        characteristics.map((c) => CNameDescription(c.name, c.description)),
        label: "Characteristics",
      ),
      CRenderLabeledListAccordion(
        links
            .mapIndexed((ix, link) => CNameDescription("Link ${ix + 1}", link)),
        innerLabel: "Choose how you became involved in the first adventure:",
        label: "Links",
      ),
    ];
  }
}

@JsonSerializable()
class CJsonFocus implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => description;

  String name;
  String description;
  List<CJsonAbilityRef> abilities;
  String intrusions;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonFocus({
    required this.name,
    required this.description,
    required this.abilities,
    required this.intrusions,
  }) : searchTextList = [
          "Name: $name",
          description,
          ...abilities.map((a) => a.searchText),
          "GM Intrusion: $intrusions",
        ];

  factory CJsonFocus.fromJson(Map<String, dynamic> json) =>
      _$CJsonFocusFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderParagraph(description),
      CRenderLabeledParagraph(label: "GM Intrusions:", text: intrusions),
      ...abilities
          .groupListsBy((a) => a.tier)
          .entries
          .map(
            (grp) => CRenderLabeledResultLinkAccordion(
              label: "Tier ${grp.key} Abilities",
              links: grp.value
                  .sorted((a, b) => a.preselected == b.preselected
                      ? 0
                      : a.preselected
                          ? -1
                          : 1)
                  .map((a) => CResultLink(
                        "${a.name}${a.preselected ? " (preselected)" : ""}",
                        resultCategory: "Abilities",
                        resultName: a.name,
                      ))
                  .toList(),
            ),
          )
          .toList(),
    ];
  }
}

@JsonSerializable()
class CJsonCypher implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => effect;

  String name;
  String effect;
  String? form;

  @JsonKey(name: "level_dice")
  String? levelDice;

  @JsonKey(name: "level_mod")
  int levelMod;

  List<CJsonRollTable> options;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonCypher({
    required this.name,
    required this.effect,
    required this.form,
    required this.levelDice,
    required this.levelMod,
    required this.options,
  }) : searchTextList = [
          "Name: $name",
          effect,
          if (form != null) "Form: $form",
          if (levelDice != null)
            "Level: $levelDice ${levelMod != 0 ? "+ $levelMod" : ""}",
          ...options
              .map((t) => t.table.map((roll) =>
                  "${roll.start == roll.end ? roll.start.toString() : "${roll.start}-${roll.end}"}: ${roll.entry}"))
              .flattened,
        ];

  factory CJsonCypher.fromJson(Map<String, dynamic> json) =>
      _$CJsonCypherFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderVerticalKeyValues([
        CNameDescription("Form", form == null ? "Any" : form!),
        if (levelDice != null)
          CNameDescription(
              "Level", "$levelDice ${levelMod != 0 ? "+ $levelMod" : ""}"),
      ]),
      CRenderParagraph(effect),
      ...options.map(
        (t) => CRenderVerticalKeyValues(
          [
            CNameDescription(
                "d${t.table.map((roll) => roll.end).max}", "Effect"),
            ...t.table.map((roll) => CNameDescription(
                roll.start == roll.end
                    ? roll.start.toString()
                    : "${roll.start}-${roll.end}",
                roll.entry)),
          ],
        ),
      ),
    ];
  }
}

@JsonSerializable()
class CJsonRollTable {
  String? name;
  List<CJsonRollEntry> table;

  CJsonRollTable({
    required this.name,
    required this.table,
  });

  factory CJsonRollTable.fromJson(Map<String, dynamic> json) =>
      _$CJsonRollTableFromJson(json);
}

@JsonSerializable()
class CJsonRollEntry {
  int start;
  int end;
  String entry;

  CJsonRollEntry({
    required this.start,
    required this.end,
    required this.entry,
  });

  factory CJsonRollEntry.fromJson(Map<String, dynamic> json) =>
      _$CJsonRollEntryFromJson(json);
}

@JsonSerializable()
class CJsonArtifact implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => effect;

  String name;

  @JsonKey(name: "level_dice")
  String? levelDice;

  @JsonKey(name: "level_mod")
  int levelMod;

  String form;
  String depletion;
  String effect;
  List<CJsonRollTable> options;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonArtifact({
    required this.name,
    required this.levelDice,
    required this.levelMod,
    required this.form,
    required this.depletion,
    required this.effect,
    required this.options,
  }) : searchTextList = [
          "Name: $name",
          effect,
          if (levelDice != null)
            "Level: $levelDice ${levelMod != 0 ? "+ $levelMod" : ""}",
          "Form: $form",
          "Depletion: $depletion",
          ...options
              .map((t) => t.table.map((roll) =>
                  "${roll.start == roll.end ? roll.start.toString() : "${roll.start}-${roll.end}"}: ${roll.entry}"))
              .flattened,
        ];

  factory CJsonArtifact.fromJson(Map<String, dynamic> json) =>
      _$CJsonArtifactFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    final depletionIsShort = depletion.length <= "Automatic".length;

    return [
      CRenderVerticalKeyValues([
        CNameDescription("Form", form),
        if (levelDice != null)
          CNameDescription(
              "Level", "$levelDice ${levelMod != 0 ? "+ $levelMod" : ""}"),
        if (depletionIsShort) CNameDescription("Depletion", depletion),
      ]),
      CRenderParagraph(effect),
      if (!depletionIsShort)
        CRenderLabeledParagraph(label: "Depletion", text: depletion),
      ...options.map(
        (t) => CRenderVerticalKeyValues(
          [
            CNameDescription(
                "d${t.table.map((roll) => roll.end).max}", "Effect"),
            ...t.table.map((roll) => CNameDescription(
                roll.start == roll.end
                    ? roll.start.toString()
                    : "${roll.start}-${roll.end}",
                roll.entry)),
          ],
        ),
      ),
    ];
  }
}

@JsonSerializable()
class CJsonCreature implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => description;

  String name;
  String kind;
  int? level;
  String description;
  String? motive;
  String? environment;
  int? health;
  String? damage;
  int armor;
  String? movement;
  List<String> modifications;
  String? combat;
  String? interactions;
  String? uses;
  String? loot;
  String? intrusions;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonCreature({
    required this.name,
    required this.kind,
    required this.level,
    required this.description,
    required this.motive,
    required this.environment,
    required this.health,
    required this.damage,
    required this.armor,
    required this.movement,
    required this.modifications,
    required this.combat,
    required this.interactions,
    required this.uses,
    required this.loot,
    required this.intrusions,
  }) : searchTextList = [
          "Name: $name",
          description,
          "Kind: $kind",
          if (level != null) "Level: $level",
          if (motive != null) "Motive: $motive",
          if (environment != null) "Environment: $environment",
          if (health != null) "Health: $health",
          if (damage != null) "Damage: $damage",
          if (armor != 0) "Armor: $armor",
          if (movement != null) "Movement: $movement",
          ...modifications.map((mod) => "Modification: $mod"),
          if (combat != null) "Combat: $combat",
          if (interactions != null) "Interactions: $interactions",
          if (uses != null) "Uses: $uses",
          if (loot != null) "Loot: $loot",
          if (intrusions != null) "GM Intrusions: $intrusions",
        ];

  factory CJsonCreature.fromJson(Map<String, dynamic> json) =>
      _$CJsonCreatureFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderVerticalKeyValues([
        CNameDescription("Level", level?.toString() ?? "Unknown"),
        if (health != null) CNameDescription("Health", health!.toString()),
        if (armor != 0) CNameDescription("Armor", armor.toString()),
        if (damage != null) CNameDescription("Damage", damage!),
        if (movement != null) CNameDescription("Movement", movement!),
        ...modifications.map((mod) => CNameDescription("Mod", mod)),
      ]),
      CRenderParagraph(description),
      if ([uses, intrusions, loot, motive, environment, combat, interactions]
          .any((it) => it != null))
        CRenderLabeledListAccordion(
          [
            if (uses != null) CNameDescription("Uses", uses!),
            if (intrusions != null)
              CNameDescription("GM Intrusions", intrusions!),
            if (loot != null) CNameDescription("Loot", loot!),
            if (motive != null) CNameDescription("Motive", motive!),
            if (environment != null)
              CNameDescription("Environment", environment!),
            if (combat != null) CNameDescription("Combat", combat!),
            if (interactions != null)
              CNameDescription("Interactions", interactions!)
          ],
          label: "Traits",
        ),
    ];
  }
}

@JsonSerializable()
class CJsonEquipment implements CSearchable {
  @override
  String get header => name;

  @override
  String get defaultDescription => variants.firstOrNull?.description ?? "";

  String name;
  List<CJsonEquipmentVariant> variants;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonEquipment({
    required this.name,
    required this.variants,
  }) : searchTextList = [
          "Name: $name",
          ...variants.map((v) => v.searchTextList).flattened,
        ];

  factory CJsonEquipment.fromJson(Map<String, dynamic> json) =>
      _$CJsonEquipmentFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    if (variants.isEmpty) {
      return [CRenderParagraph("It's just a $name.")];
    }

    if (variants.length == 1) {
      return variants.first.getRenderables();
    }

    final defaultVariant =
        variants.firstWhereOrNull((v) => v.description.isEmpty) ??
            variants.first;
    final otherVariants = variants.where((v) => v != defaultVariant);

    return [
      ...defaultVariant.getRenderables(),
      if (otherVariants.isNotEmpty) ...[
        const CRenderSectionLabel("Variants"),
        ...otherVariants.mapIndexed(
          (ix, v) => CRenderAccordion(
            label: "Variant ${ix + 1}",
            content:
                CRenderInternalColumn(children: v.getRenderables().toList()),
          ),
        )
      ],
    ];
  }
}

@JsonSerializable()
class CJsonEquipmentVariant implements CSearchableComplexItem {
  String description;
  Set<String> notes;
  Set<String> tags;
  List<String> value;
  List<int> levels;

  @override
  @JsonKey(includeFromJson: false)
  Iterable<String> searchTextList;

  CJsonEquipmentVariant({
    required this.description,
    required this.notes,
    required this.tags,
    required this.value,
    required this.levels,
  }) : searchTextList = [
          "Variant: $description",
          ...notes.map((note) => "Note: $note"),
          ...value.map((val) => "Value: $val"),
          ...levels.map((l) => "Level: $l"),
          ...tags.map((tag) => "Tag: $tag"),
        ];

  factory CJsonEquipmentVariant.fromJson(Map<String, dynamic> json) =>
      _$CJsonEquipmentVariantFromJson(json);

  @override
  Iterable<Widget> getRenderables() {
    return [
      CRenderVerticalKeyValues([
        CNameDescription("Level", levels.isEmpty ? "Any" : levels.join(", ")),
        CNameDescription("Value", value.isEmpty ? "Any" : value.join("/")),
      ]),
      if (description.isNotEmpty) CRenderParagraph(description),
      if (notes.isNotEmpty)
        CRenderLinksParagraph(
            label: "Notes",
            textQueries: notes
                .map((note) => CSearchQueryLink(note, "Note: $note"))
                .toList()),
      if (tags.isNotEmpty)
        CRenderLinksParagraph(
          label: "Tags",
          textQueries:
              tags.map((tag) => CSearchQueryLink(tag, "Tag: $tag")).toList(),
        )
    ];
  }
}
