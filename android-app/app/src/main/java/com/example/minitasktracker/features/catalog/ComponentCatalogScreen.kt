package com.example.minitasktracker.features.catalog

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.minitasktracker.core.ui.components.*
import com.example.minitasktracker.core.ui.theme.Spacing
import com.example.minitasktracker.domain.model.Priority
import com.example.minitasktracker.domain.model.Role
import com.example.minitasktracker.domain.model.Task
import com.example.minitasktracker.domain.model.TaskStatus
import com.example.minitasktracker.domain.model.User
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * Component Catalog - Tüm UI bileşenlerinin önizleme ekranı
 * Not: Bu ekran sadece geliştirme amaçlı kullanılır
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ComponentCatalogScreen(
    onNavigateBack: () -> Unit
) {
    var showConfirmDialog by remember { mutableStateOf(false) }
    var showAlertDialog by remember { mutableStateOf(false) }
    var showSuccessSnackbar by remember { mutableStateOf(false) }
    var showErrorSnackbar by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("UI Component Catalog") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, "Geri")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(Spacing.screenPadding),
            verticalArrangement = Arrangement.spacedBy(Spacing.spacing24)
        ) {
            // Buttons Section
            ButtonsSection()

            AppDivider()

            // Text Fields Section
            TextFieldsSection()

            AppDivider()

            // Badges Section
            BadgesSection()

            AppDivider()

            // Task Card Section
            TaskCardSection()

            AppDivider()

            // Empty States Section
            EmptyStatesSection()

            AppDivider()

            // Form Controls Section
            FormControlsSection()

            AppDivider()

            // Filter Bar Section
            FilterBarSection()

            AppDivider()

            // Dialog Triggers Section
            DialogTriggersSection(
                onShowConfirmDialog = { showConfirmDialog = true },
                onShowAlertDialog = { showAlertDialog = true }
            )

            AppDivider()

            // Snackbar Triggers Section
            SnackbarTriggersSection(
                onShowSuccessSnackbar = { showSuccessSnackbar = true },
                onShowErrorSnackbar = { showErrorSnackbar = true }
            )

            Spacer(modifier = Modifier.height(Spacing.spacing32))
        }

        // Dialogs
        if (showConfirmDialog) {
            ConfirmDialog(
                onDismiss = { showConfirmDialog = false },
                onConfirm = { showConfirmDialog = false },
                title = "Silmek istediğinize emin misiniz?",
                message = "Bu işlem geri alınamaz."
            )
        }

        if (showAlertDialog) {
            AlertDialog(
                onDismiss = { showAlertDialog = false },
                title = "Başarılı",
                message = "İşlem tamamlandı."
            )
        }

        // Snackbars
        if (showSuccessSnackbar) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(Spacing.spacing16)
            ) {
                SuccessSnackbar(
                    message = "İşlem başarılı!",
                    onDismiss = { showSuccessSnackbar = false }
                )
            }
        }

        if (showErrorSnackbar) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(Spacing.spacing16)
            ) {
                ErrorSnackbar(
                    message = "Bir hata oluştu",
                    actionLabel = "Tekrar Dene",
                    onActionClick = { showErrorSnackbar = false },
                    onDismiss = { showErrorSnackbar = false }
                )
            }
        }
    }
}

@Composable
private fun ButtonsSection() {
    SectionHeader(title = "Buttons")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    // Primary
    AppButton(
        text = "Primary Button",
        onClick = {},
        variant = ButtonVariant.PRIMARY
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    // Secondary
    AppButton(
        text = "Secondary Button",
        onClick = {},
        variant = ButtonVariant.SECONDARY
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    // Tertiary
    AppButton(
        text = "Tertiary Button",
        onClick = {},
        variant = ButtonVariant.TERTIARY
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    // Destructive
    AppButton(
        text = "Destructive Button",
        onClick = {},
        variant = ButtonVariant.DESTRUCTIVE
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    // Ghost
    AppButton(
        text = "Ghost Button",
        onClick = {},
        variant = ButtonVariant.GHOST
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    // Disabled
    AppButton(
        text = "Disabled Button",
        onClick = {},
        enabled = false
    )

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    // Sizes
    Text(
        text = "Button Sizes",
        style = MaterialTheme.typography.labelLarge
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
    ) {
        AppButton(
            text = "Small",
            onClick = {},
            size = ButtonSize.SMALL
        )
        AppButton(
            text = "Medium",
            onClick = {},
            size = ButtonSize.MEDIUM
        )
        AppButton(
            text = "Large",
            onClick = {},
            size = ButtonSize.LARGE
        )
    }
}

@Composable
private fun TextFieldsSection() {
    var textValue by remember { mutableStateOf("") }
    var passwordValue by remember { mutableStateOf("") }
    var textAreaValue by remember { mutableStateOf("") }
    var errorValue by remember { mutableStateOf("") }

    SectionHeader(title = "Text Fields")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppTextField(
        value = textValue,
        onValueChange = { textValue = it },
        label = "Standart Text Field",
        helperText = "Yardımcı metin burada görünür"
    )

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppTextField(
        value = textValue,
        onValueChange = { textValue = it },
        label = "İkonlu Text Field",
        leadingIcon = Icons.Default.Edit,
        isRequired = true
    )

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppTextField(
        value = passwordValue,
        onValueChange = { passwordValue = it },
        label = "Şifre",
        isPassword = true
    )

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppTextField(
        value = errorValue,
        onValueChange = { errorValue = it },
        label = "Disabled Durum",
        enabled = false
    )

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppTextArea(
        value = textAreaValue,
        onValueChange = { textAreaValue = it },
        label = "Text Area",
        minLines = 3,
        maxLines = 5
    )
}

@Composable
private fun BadgesSection() {
    SectionHeader(title = "Badges")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Text(
        text = "Status Badges",
        style = MaterialTheme.typography.labelLarge
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
    ) {
        StatusBadge(status = TaskStatus.TODO)
        StatusBadge(status = TaskStatus.IN_PROGRESS)
        StatusBadge(status = TaskStatus.DONE)
    }

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Text(
        text = "Priority Badges",
        style = MaterialTheme.typography.labelLarge
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
    ) {
        PriorityBadge(priority = Priority.LOW)
        PriorityBadge(priority = Priority.NORMAL)
        PriorityBadge(priority = Priority.HIGH)
    }

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Text(
        text = "User Avatar",
        style = MaterialTheme.typography.labelLarge
    )

    Spacer(modifier = Modifier.height(Spacing.spacing8))

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
    ) {
        UserAvatar(name = "Ahmet Yılmaz")
        UserAvatar(name = "Zeynep Kaya")
        UserAvatar(name = "Mehmet Can")
    }
}

@Composable
private fun TaskCardSection() {
    val now = LocalDateTime.now()
    val formatter = DateTimeFormatter.ISO_DATE_TIME
    
    val sampleTask = Task(
        id = "1",
        topicId = "backend",
        topicTitle = "Backend",
        title = "API Entegrasyonu",
        note = "Backend servisleri ile entegrasyon yapılacak",
        assigneeId = "user1",
        assigneeName = "Ahmet Yılmaz",
        status = TaskStatus.IN_PROGRESS,
        priority = Priority.HIGH,
        dueDate = now.plusDays(3).format(formatter),
        createdAt = now.minusDays(2).format(formatter),
        updatedAt = now.format(formatter),
        completedAt = null
    )

    SectionHeader(title = "Task Card")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    TaskCard(
        task = sampleTask,
        onStatusChange = {},
        onClick = {},
        showNote = true
    )
}

@Composable
private fun EmptyStatesSection() {
    SectionHeader(title = "Empty States")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Surface(
        modifier = Modifier.height(250.dp),
        color = MaterialTheme.colorScheme.surface,
        tonalElevation = 1.dp,
        shape = MaterialTheme.shapes.medium
    ) {
        NoTasksEmptyState(onCreateClick = {})
    }

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Surface(
        modifier = Modifier.height(250.dp),
        color = MaterialTheme.colorScheme.surface,
        tonalElevation = 1.dp,
        shape = MaterialTheme.shapes.medium
    ) {
        NoSearchResultsEmptyState(searchQuery = "test")
    }
}

@Composable
private fun FormControlsSection() {
    var checkboxChecked by remember { mutableStateOf(false) }
    var switchChecked by remember { mutableStateOf(true) }

    SectionHeader(title = "Form Controls")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppCheckbox(
        checked = checkboxChecked,
        onCheckedChange = { checkboxChecked = it },
        label = "Checkbox Label"
    )

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    AppSwitch(
        checked = switchChecked,
        onCheckedChange = { switchChecked = it },
        label = "Switch Label",
        description = "Switch açıklama metni burada görünür"
    )
}

@Composable
private fun FilterBarSection() {
    var searchQuery by remember { mutableStateOf("") }
    var selectedFilters by remember { mutableStateOf(setOf<String>()) }

    val filters = listOf(
        Filter("high", "Yüksek Öncelik"),
        Filter("todo", "Yapılacak"),
        Filter("done", "Tamamlandı")
    )

    SectionHeader(title = "Filter Bar")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    FilterBar(
        searchQuery = searchQuery,
        onSearchChange = { searchQuery = it },
        filters = filters,
        selectedFilters = selectedFilters,
        onFilterToggle = { id ->
            selectedFilters = if (selectedFilters.contains(id)) {
                selectedFilters - id
            } else {
                selectedFilters + id
            }
        },
        onClearAll = { selectedFilters = emptySet() }
    )
}

@Composable
private fun DialogTriggersSection(
    onShowConfirmDialog: () -> Unit,
    onShowAlertDialog: () -> Unit
) {
    SectionHeader(title = "Dialogs")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
    ) {
        AppButton(
            text = "Confirm Dialog",
            onClick = onShowConfirmDialog,
            modifier = Modifier.weight(1f),
            variant = ButtonVariant.TERTIARY
        )
        AppButton(
            text = "Alert Dialog",
            onClick = onShowAlertDialog,
            modifier = Modifier.weight(1f),
            variant = ButtonVariant.TERTIARY
        )
    }
}

@Composable
private fun SnackbarTriggersSection(
    onShowSuccessSnackbar: () -> Unit,
    onShowErrorSnackbar: () -> Unit
) {
    SectionHeader(title = "Snackbars")

    Spacer(modifier = Modifier.height(Spacing.spacing12))

    Row(
        horizontalArrangement = Arrangement.spacedBy(Spacing.spacing8)
    ) {
        AppButton(
            text = "Success Snackbar",
            onClick = onShowSuccessSnackbar,
            modifier = Modifier.weight(1f),
            variant = ButtonVariant.SECONDARY
        )
        AppButton(
            text = "Error Snackbar",
            onClick = onShowErrorSnackbar,
            modifier = Modifier.weight(1f),
            variant = ButtonVariant.DESTRUCTIVE
        )
    }
}
