import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:m_and_r_quiz_admin_panel/components/app_bar/my_app_bar.dart';
import 'package:m_and_r_quiz_admin_panel/components/html_editor/nk_quill_editor.dart';
import 'package:m_and_r_quiz_admin_panel/components/nk_image_picker_with_placeholder/nk_image_picker_with_placeholder.dart';
import 'package:m_and_r_quiz_admin_panel/components/nk_number_counter/nk_number_counter_field.dart';
import 'package:m_and_r_quiz_admin_panel/export/___app_file_exporter.dart';
import 'package:m_and_r_quiz_admin_panel/view/category/diloag/add_category_diloag.dart';
import 'package:m_and_r_quiz_admin_panel/view/category/diloag/model/quiz_add_editor_model.dart';
import 'package:m_and_r_quiz_admin_panel/view/category/model/category_response.dart';
import 'package:m_and_r_quiz_admin_panel/view/utills_management/file_type_management/model/file_type_response.dart';

class QuizAddFormWidget extends StatefulWidget {
  final CategoryData? categoryDataModel;
  final Function(CategoryData? catData)? onUpdated;
  final CategoryTypeENUM categoryType;
  final FileTypeData fileTypeModel;
  final String? parentId;
  const QuizAddFormWidget(
      {super.key,
      this.categoryDataModel,
      this.onUpdated,
      required this.categoryType,
      required this.fileTypeModel,
      this.parentId});

  @override
  State<QuizAddFormWidget> createState() => _QuizAddFormWidgetState();
}

class _QuizAddFormWidgetState extends State<QuizAddFormWidget> {
  final List<QuizAddEditorModel> quizAddEditorModelList = [
    QuizAddEditorModel(
        controller: QuillController.basic(editorFocusNode: FocusNode()),
        hint: "Title"),
    QuizAddEditorModel(
        controller: QuillController.basic(editorFocusNode: FocusNode()),
        hint: "Sub Title"),
  ];
  QuillController? focusedController;

  List<QuizAddQustionEditorModel> questionList = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: transparent,
      alignment: Alignment.center,
      title: Column(
        children: [
          MyCommnonContainer(
            padding: 16.horizontal,
            child: MyAppBar(
              heading: widget.categoryDataModel != null
                  ? "$editStr ${widget.fileTypeModel.typeName}"
                  : "$addStr ${widget.fileTypeModel.typeName}",
            ),
          ),
          10.space,
          if (focusedController != null) ...[
            MyCommnonContainer(
              height: context.isTablet || context.isMobile ? 180 : null,
              width: context.isLargeDesktop
                  ? null
                  : context.isTablet || context.isMobile
                      ? context.width
                      : null,
              padding: 0.all,
              child: NkQuillToolbar(
                controller: focusedController,
              ),
            ),
          ],
        ],
      ),
      content: AlertDialog(
        backgroundColor: transparent,
        contentPadding: 0.all,
        titlePadding: 0.all.copyWith(bottom: nkRegularPadding.bottom),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth:
                    context.isMobile ? context.width : context.width * 0.45),
            child: _body(context),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        MyCommnonContainer(
          padding: nkRegularPadding.copyWith(
            top: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _examThumbnail()),
              const MyRegularText(label: titleStr),
              _quizTitle(quizAddEditorModelList.first),
              const MyRegularText(label: subTitleStr),
              _quizSubTitle(quizAddEditorModelList[1]),
            ].addSpaceEveryWidget(space: nkExtraSmallSizedBox),
          ),
        ),
        nkSmallSizedBox,
        _QuestionListWidget(
          questionList: questionList,
          onQuestionChanged: (quillController) {
            setState(() {
              focusedController = quillController;
            });
          },
        ),
        nkSmallSizedBox,
        Align(
          alignment: Alignment.bottomRight,
          child: FittedBox(
            child: MyThemeButton(
              padding: 10.horizontal,
              leadingIcon: const Icon(
                Icons.add,
                color: secondaryIconColor,
              ),
              buttonText: "$addStr $questionStr",
              onPressed: onAddQuestion,
            ),
          ),
        )
      ],
    );
  }

  onAddQuestion() {
    setState(() {
      questionList.add(
        QuizAddQustionEditorModel(
          questionController: QuizAddEditorModel(
            hint: "Question",
            controller: QuillController.basic(editorFocusNode: FocusNode()),
          ),
        ),
      );
    });
  }

  Widget _examThumbnail() {
    return const NkPickerWithPlaceHolder(
      fileType: "image",
      pickType: FileType.image,
      lableText: headingImageStr,
    );
  }

  Widget _quizTitle(QuizAddEditorModel quizAddEditorModel) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        setState(() {
          focusedController = quizAddEditorModel.controller;
        });

        // quizAddEditorModel.controller.editorFocusNode?.requestFocus();

        nkDevLog("FOCUSED WIDGET : $focusedController");
      },
      child: NkQuillEditor(
        unSelect: (unSelected) {
          setState(() {
            focusedController = null;
          });
        },
        isSelected: focusedController == quizAddEditorModel.controller,
        hint: quizAddEditorModel.hint,
        controller: quizAddEditorModel.controller,
        // controller: QuillEditorController(),
      ),
    );
  }

  Widget _quizSubTitle(QuizAddEditorModel quizAddEditorModel) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        setState(() {
          focusedController = quizAddEditorModel.controller;
        });

        nkDevLog("FOCUSED WIDGET : $focusedController");
      },
      child: NkQuillEditor(
        unSelect: (unSelected) {
          setState(() {
            focusedController = null;
          });
        },
        isSelected: focusedController == quizAddEditorModel.controller,
        hint: quizAddEditorModel.hint,
        controller: quizAddEditorModel.controller,
      ),
    );
  }
}

class _QuestionListWidget extends StatefulWidget {
  final List<QuizAddQustionEditorModel> questionList;
  final Function(QuillController? quillController)? onQuestionChanged;
  const _QuestionListWidget(
      {required this.questionList, this.onQuestionChanged});

  @override
  State<_QuestionListWidget> createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends State<_QuestionListWidget> {
  List<QuizAddQustionEditorModel> questionList = [];
  QuizQuestionOptionsEditorModel? currectAnswer;

  @override
  void initState() {
    questionList = widget.questionList;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _QuestionListWidget oldWidget) {
    questionList = widget.questionList;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(questionList.length, (index) {
        return questionListWidget(context, index, questionList[index]);
      }).addSpaceEveryWidget(space: 10.space),
    );
  }

  onAddOption(QuizAddQustionEditorModel question) {
    question.options ??= [];
    setState(() {
      question.options?.add(
        QuizQuestionOptionsEditorModel(
          optionController: QuizAddEditorModel(
            hint: "Option",
            controller: QuillController.basic(editorFocusNode: FocusNode()),
          ),
        ),
      );
    });
  }

  Widget questionListWidget(BuildContext context, int index,
      QuizAddQustionEditorModel quizAddQustionEditorModel) {
    return MyCommnonContainer(
      padding: 10.all,
      child: Column(
        children: [
          _showOtherOption(quizAddQustionEditorModel, index),
          _questionTitle(quizAddQustionEditorModel.questionController, index),
          _optionList(quizAddQustionEditorModel, index),
        ].addSpaceEveryWidget(space: 5.space),
      ),
    );
  }

  Widget _showOtherOption(
      QuizAddQustionEditorModel quizAddQustionEditorModel, int index) {
    return Align(
      alignment: Alignment.topRight,
      child: PopupMenuButton(itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: () {
              setState(() {
                questionList.removeAt(index);
              });
            },
            child: const MyRegularText(
              label: removeStr,
              color: errorColor,
            ),
          ),
        ];
      }),
    );
  }

  Widget _questionTitle(QuizAddEditorModel quizAddEditorModel, int index) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        widget.onQuestionChanged?.call(quizAddEditorModel.controller);
      },
      child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: 0.all,
        leading: MyRegularText(
          label: "${index + 1}.",
        ),
        title: NkQuillEditor(
          border: const Border(bottom: BorderSide(color: textFieldBorderColor)),
          hint: quizAddEditorModel.hint,
          controller: quizAddEditorModel.controller,
          // controller: QuillEditorController(),
        ),
      ),
    );
  }

  Widget _optionList(
      QuizAddQustionEditorModel quizAddQustionEditorModel, int perentIndex) {
    if (quizAddQustionEditorModel.options != null &&
        quizAddQustionEditorModel.options?.isNotEmpty == true) {
      return Column(
        children: [
          Column(
            children: List.generate(
              quizAddQustionEditorModel.options?.length ?? 0,
              (index) {
                return _optionWidget(quizAddQustionEditorModel.options![index],
                    perentIndex, index);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton.icon(
                style: const ButtonStyle(
                  iconColor: WidgetStatePropertyAll(primaryIconColor),
                ),
                onPressed: () {
                  onAddOption(quizAddQustionEditorModel);
                },
                label: MyRegularText(
                  label: "$addStr $optionStr",
                  fontSize: NkFontSize.smallFont,
                ),
                icon: const Icon(
                  Icons.add,
                  color: primaryIconColor,
                )),
          ),
          nkExtraSmallSizedBox,
          if (quizAddQustionEditorModel.ansOption != null) ...[
            _answerWidget(quizAddQustionEditorModel
                .ansOption!.optionController.controller)
          ],
          _durationWidget(),
        ],
      );
    } else {
      return TextButton.icon(
          style: const ButtonStyle(
            iconColor: WidgetStatePropertyAll(primaryIconColor),
          ),
          onPressed: () {
            onAddOption(quizAddQustionEditorModel);
          },
          label: MyRegularText(
            label: "$addStr $optionStr",
            fontSize: NkFontSize.smallFont,
          ),
          icon: const Icon(
            Icons.add,
            color: primaryIconColor,
          ));
    }
  }

  Widget _optionWidget(
      QuizQuestionOptionsEditorModel model, int perentIndex, int index) {
    return CheckboxListTile.adaptive(
      hoverColor: transparent,
      tileColor: transparent,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: 0.all,
      value: questionList[perentIndex].ansOption == model,
      onChanged: (value) {
        setState(() {
          questionList[perentIndex].ansOption = model;
          // currectAnswer = model;
        });
      },
      title: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          widget.onQuestionChanged?.call(model.optionController.controller);
        },
        child: NkQuillEditor(
          border: const Border(bottom: BorderSide(color: textFieldBorderColor)),
          hint: model.optionController.hint,
          controller: model.optionController.controller,
          // controller: QuillEditorController(),
        ),
      ),
      secondary: IconButton(
          onPressed: () {
            setState(() {
              questionList[perentIndex].options?.removeAt(index);
            });
          },
          icon: const Icon(
            Icons.remove,
            color: errorColor,
          )),
    );
  }

  Widget _answerWidget(QuillController controller) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyRegularText(
          label: "$ansStr.",
          fontWeight: NkGeneralSize.nkBoldFontWeight,
        ),
        Flexible(
          child: NkQuillEditor(
            isReaDOnly: true,
            border: Border.all(color: transparent),

            controller: controller,
            // controller: QuillEditorController(),
          ),
        ),
      ],
    );
  }

  Widget _durationWidget() {
    return Row(
      children: [
        MyCommnonContainer(
            padding: 4.all, color: lightGreyColor, child: NkTimeCounterField()),
      ],
    );
  }
}
