#include "NineChessAi_ab.h"

NineChessAi_ab::NineChessAi_ab():
rootNode(nullptr),
requiredQuit(false),
depth(5)    // Ĭ��5�����
{
}

NineChessAi_ab::~NineChessAi_ab()
{
    deleteTree(rootNode);
}

void NineChessAi_ab::buildChildren(Node *node)
{
    ;
}

void NineChessAi_ab::sortChildren(Node *node)
{
    // ���������Ч�ʵ�Ӱ��ܴ�
    // ����õĻ�����֦���磬��ʡʱ��
    // �������ڴ˺����ķ�̫��ʱ��
    ;
}

void NineChessAi_ab::deleteTree(Node *node)
{
    if (rootNode) {
        for (auto i : rootNode->children) {
            deleteTree(i);
        }
        rootNode->children.clear();
        delete rootNode;
    }
}

void NineChessAi_ab::setChess(const NineChess &chess)
{
    this->chess = chess;
    chessTemp = chess;
    requiredQuit = false;
}

int NineChessAi_ab::evaluate(Node *node)
{
    // ��ʼ����ֵΪ0�����������������󣬶Ժ����������С
    int value = 0;




    // ��ֵ����
    node->value = value;
    return value;
}

int NineChessAi_ab::alphaBetaPruning(int depth, int alpha, int beta, Node *node)
{
    // ����ֵ
    int value;
    if (!depth || !(node->children.size())) {
        node->value = evaluate(node);
        return node->value;
    }

    // �����ӽڵ���
    buildChildren(node);
    // �����ӽڵ���
    sortChildren(node);

    // ��������ģ��ִ��MiniMax����
    // �����֣�����Max
    if (chessTemp.whosTurn() == NineChess::PLAYER1) {
        for (auto child : node->children) {
            value = alphaBetaPruning(depth - 1, alpha, beta, child);
            // ȡ���ֵ
            if (value > alpha)
                alpha = value;
            // ��֦����
            if (alpha >= beta) {
                return value;
            }
        }
        // ȡ���ֵ
        node->value = alpha;
    }
    // �Ժ��֣�����Min
    else {
        for (auto child : node->children) {
            value = alphaBetaPruning(depth - 1, alpha, beta, child);
            // ȡ��Сֵ
            if (value < beta)
                beta = value;
            // ��֦����
            if (alpha >= beta) {
                return value;
            }
        }
        // ȡ��Сֵ
        node->value = beta;
    }
    // ����
    return node->value;
}

